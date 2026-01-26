import AVFoundation
import WhisperKit

// MARK: - Whisper Recognizer

/// WhisperKit 기반 On-device 음성 인식 구현체
@MainActor
final class WhisperRecognizer: NSObject, SpeechRecognizing {

    // MARK: - Dependencies

    private let audioSession: AudioSessionManaging
    private var whisperKit: WhisperKit?

    // MARK: - State

    private(set) var isRecognizing: Bool = false
    private(set) var authorizationStatus: SpeechAuthorizationStatus = .notDetermined

    // MARK: - Internal Components

    private var audioEngine: AVAudioEngine?
    fileprivate var audioBuffer: [Float] = []
    private var recognitionTask: Task<Void, Never>?

    // MARK: - AsyncStream

    private var continuation: AsyncStream<SpeechRecognitionResult>.Continuation?

    var recognitionResults: AsyncStream<SpeechRecognitionResult> {
        return AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    // MARK: - Configuration

    private let modelName: String
    private let sampleRate: Double = 16000.0

    // MARK: - Initialization

    init(
        modelName: String = "openai_whisper-base.en",
        audioSession: AudioSessionManaging? = nil
    ) {
        self.modelName = modelName
        self.audioSession = audioSession ?? AudioSessionManager()
        super.init()

        // 마이크 권한 상태 확인
        updateAuthorizationStatus()
    }

    // MARK: - Public Methods

    func requestAuthorization() async -> SpeechAuthorizationStatus {
        // WhisperKit은 마이크 권한만 필요
        let status: AVAudioApplication.recordPermission = AVAudioApplication.shared.recordPermission

        switch status {
        case .undetermined:
            let granted: Bool = await AVAudioApplication.requestRecordPermission()
            authorizationStatus = granted ? .authorized : .denied
        case .denied:
            authorizationStatus = .denied
        case .granted:
            authorizationStatus = .authorized
        @unknown default:
            authorizationStatus = .denied
        }

        return authorizationStatus
    }

    func startRecognition() async throws {
        // 권한 확인
        guard authorizationStatus == .authorized else {
            throw SpeechRecognitionError.notAuthorized
        }

        // 이미 인식 중이면 중지
        if isRecognizing {
            stopRecognition()
        }

        // WhisperKit 초기화 (최초 1회)
        if whisperKit == nil {
            do {
                let config: WhisperKitConfig = WhisperKitConfig(model: modelName)
                whisperKit = try await WhisperKit(config)
            } catch {
                throw SpeechRecognitionError.notAvailable
            }
        }

        // 오디오 세션 설정
        do {
            try audioSession.configureForRecording()
        } catch {
            throw SpeechRecognitionError.audioEngineError
        }

        // 오디오 버퍼 초기화
        audioBuffer = []

        // 오디오 엔진 설정
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw SpeechRecognitionError.audioEngineError
        }

        // 오디오 입력 설정
        let inputNode: AVAudioInputNode = audioEngine.inputNode
        let recordingFormat: AVAudioFormat = inputNode.outputFormat(forBus: 0)

        // 16kHz로 리샘플링이 필요한 경우를 위한 컨버터 설정
        let targetFormat: AVAudioFormat? = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )

        guard let targetFormat = targetFormat else {
            throw SpeechRecognitionError.audioEngineError
        }

        let converter: AVAudioConverter? = AVAudioConverter(from: recordingFormat, to: targetFormat)

        // 오디오 탭 설치
        installAudioTap(
            on: inputNode,
            format: recordingFormat,
            targetFormat: targetFormat,
            converter: converter
        )

        // 오디오 엔진 시작
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecognizing = true

            // 실시간 전사를 위한 주기적 처리 태스크 시작
            startPeriodicTranscription()
        } catch {
            cleanup()
            throw SpeechRecognitionError.audioEngineError
        }
    }

    func stopRecognition() {
        // 오디오 엔진 중지
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)

        // 주기적 전사 태스크 취소
        recognitionTask?.cancel()
        recognitionTask = nil

        // 최종 전사 수행
        Task {
            await performFinalTranscription()
        }

        // 상태 업데이트
        isRecognizing = false

        // 정리
        cleanup()
    }

    // MARK: - Private Methods

    /// 권한 상태 업데이트
    private func updateAuthorizationStatus() {
        let status: AVAudioApplication.recordPermission = AVAudioApplication.shared.recordPermission

        switch status {
        case .undetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .granted:
            authorizationStatus = .authorized
        @unknown default:
            authorizationStatus = .denied
        }
    }

    /// 주기적 전사 시작 (실시간 피드백용)
    private func startPeriodicTranscription() {
        recognitionTask = Task { [weak self] in
            while !Task.isCancelled {
                // 1.5초마다 중간 결과 전송
                try? await Task.sleep(nanoseconds: 1_500_000_000)

                guard let self = self, self.isRecognizing else { break }

                await self.performIntermediateTranscription()
            }
        }
    }

    /// 중간 전사 수행
    private func performIntermediateTranscription() async {
        guard !audioBuffer.isEmpty, let whisperKit = whisperKit else { return }

        let bufferCopy: [Float] = audioBuffer

        do {
            let results: [TranscriptionResult] = try await whisperKit.transcribe(audioArray: bufferCopy)

            if let result: TranscriptionResult = results.first {
                let segments: [SpeechSegment] = result.segments.map { segment in
                    SpeechSegment(
                        text: segment.text,
                        confidence: 0.8, // WhisperKit은 세그먼트별 confidence를 제공하지 않음
                        timestamp: TimeInterval(segment.start),
                        duration: TimeInterval(segment.end - segment.start)
                    )
                }

                let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
                    text: result.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    isFinal: false,
                    segments: segments,
                    confidence: 0.8
                )

                continuation?.yield(recognitionResult)
            }
        } catch {
            // 중간 전사 실패는 무시 (최종 전사에서 재시도)
        }
    }

    /// 최종 전사 수행
    private func performFinalTranscription() async {
        guard !audioBuffer.isEmpty, let whisperKit = whisperKit else {
            continuation?.finish()
            return
        }

        let bufferCopy: [Float] = audioBuffer

        do {
            let results: [TranscriptionResult] = try await whisperKit.transcribe(audioArray: bufferCopy)

            if let result: TranscriptionResult = results.first {
                let segments: [SpeechSegment] = result.segments.map { segment in
                    SpeechSegment(
                        text: segment.text,
                        confidence: 0.9,
                        timestamp: TimeInterval(segment.start),
                        duration: TimeInterval(segment.end - segment.start)
                    )
                }

                let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
                    text: result.text.trimmingCharacters(in: .whitespacesAndNewlines),
                    isFinal: true,
                    segments: segments,
                    confidence: 0.9
                )

                continuation?.yield(recognitionResult)
            }
        } catch {
            // 전사 실패 시 빈 결과 반환
            let emptyResult: SpeechRecognitionResult = SpeechRecognitionResult(
                text: "",
                isFinal: true,
                segments: [],
                confidence: 0.0
            )
            continuation?.yield(emptyResult)
        }

        continuation?.finish()
    }

    /// 오디오 탭 설치 (nonisolated - Sendable closure 처리용)
    nonisolated private func installAudioTap(
        on inputNode: AVAudioInputNode,
        format recordingFormat: AVAudioFormat,
        targetFormat: AVAudioFormat,
        converter: AVAudioConverter?
    ) {
        let helper: AudioTapHelper = AudioTapHelper(
            recognizer: self,
            targetFormat: targetFormat,
            converter: converter,
            targetSampleRate: 16000.0,
            sourceSampleRate: recordingFormat.sampleRate
        )

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat,
            block: helper.handleAudioBuffer
        )
    }

    /// 리소스 정리
    private func cleanup() {
        audioEngine = nil
        audioBuffer = []

        // 오디오 세션 비활성화
        try? audioSession.deactivate()
    }
}

// MARK: - Audio Tap Helper

/// 오디오 탭 처리를 위한 헬퍼 클래스
/// Sendable closure 내에서 안전하게 오디오 데이터를 처리
private final class AudioTapHelper: Sendable {
    private let recognizer: WhisperRecognizer
    private let targetFormat: AVAudioFormat
    private let converter: AVAudioConverter?
    private let targetSampleRate: Double
    private let sourceSampleRate: Double

    init(
        recognizer: WhisperRecognizer,
        targetFormat: AVAudioFormat,
        converter: AVAudioConverter?,
        targetSampleRate: Double,
        sourceSampleRate: Double
    ) {
        self.recognizer = recognizer
        self.targetFormat = targetFormat
        self.converter = converter
        self.targetSampleRate = targetSampleRate
        self.sourceSampleRate = sourceSampleRate
    }

    func handleAudioBuffer(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        var samples: [Float] = []

        // 리샘플링 (필요한 경우)
        if let converter: AVAudioConverter = converter {
            let ratio: Double = targetSampleRate / sourceSampleRate
            let outputFrameCapacity: AVAudioFrameCount = AVAudioFrameCount(Double(buffer.frameLength) * ratio)

            guard let convertedBuffer: AVAudioPCMBuffer = AVAudioPCMBuffer(
                pcmFormat: targetFormat,
                frameCapacity: outputFrameCapacity
            ) else { return }

            var error: NSError?
            let inputBlock: AVAudioConverterInputBlock = { (_: AVAudioFrameCount, outStatus: UnsafeMutablePointer<AVAudioConverterInputStatus>) -> AVAudioBuffer? in
                outStatus.pointee = .haveData
                return buffer
            }
            converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)

            if error == nil, let floatData: UnsafeMutablePointer<Float> = convertedBuffer.floatChannelData?[0] {
                samples = Array(UnsafeBufferPointer(
                    start: floatData,
                    count: Int(convertedBuffer.frameLength)
                ))
            }
        } else if let floatData: UnsafeMutablePointer<Float> = buffer.floatChannelData?[0] {
            samples = Array(UnsafeBufferPointer(
                start: floatData,
                count: Int(buffer.frameLength)
            ))
        }

        if !samples.isEmpty {
            Task { @MainActor in
                self.recognizer.audioBuffer.append(contentsOf: samples)
            }
        }
    }
}
