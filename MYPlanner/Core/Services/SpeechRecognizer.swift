import AVFoundation
import Speech

// MARK: - Speech Recognizer

/// iOS Speech Framework 기반 음성 인식 구현체
final class SpeechRecognizer: NSObject, SpeechRecognizing {

    // MARK: - Dependencies

    private let speechRecognizer: SFSpeechRecognizer
    private let audioSession: AudioSessionManaging

    // MARK: - State

    private(set) var isRecognizing: Bool = false
    private(set) var authorizationStatus: SpeechAuthorizationStatus = .notDetermined

    // MARK: - Internal Components

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: - AsyncStream

    private var continuation: AsyncStream<SpeechRecognitionResult>.Continuation?

    var recognitionResults: AsyncStream<SpeechRecognitionResult> {
        return AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    // MARK: - Initialization

    init(
        locale: Locale = Locale(identifier: "en-US"),
        audioSession: AudioSessionManaging = AudioSessionManager()
    ) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer()!
        self.audioSession = audioSession
        super.init()

        // 초기 권한 상태 확인
        updateAuthorizationStatus()
    }

    // MARK: - Public Methods

    func requestAuthorization() async -> SpeechAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                let mappedStatus: SpeechAuthorizationStatus = self?.mapAuthorizationStatus(status) ?? .denied
                self?.authorizationStatus = mappedStatus
                continuation.resume(returning: mappedStatus)
            }
        }
    }

    func startRecognition() async throws {
        // 권한 확인
        guard authorizationStatus == .authorized else {
            throw SpeechRecognitionError.notAuthorized
        }

        // 음성 인식 가용성 확인
        guard speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.notAvailable
        }

        // 이미 인식 중이면 중지
        if isRecognizing {
            stopRecognition()
        }

        // 오디오 세션 설정
        do {
            try audioSession.configureForRecording()
        } catch {
            throw SpeechRecognitionError.audioEngineError
        }

        // 오디오 엔진 설정
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw SpeechRecognitionError.audioEngineError
        }

        // 인식 요청 생성
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.audioEngineError
        }

        // 실시간 결과 활성화
        recognitionRequest.shouldReportPartialResults = true

        // iOS 16+ 에서 on-device 인식 시도
        if #available(iOS 16.0, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        // 인식 태스크 시작
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            self?.handleRecognitionResult(result: result, error: error)
        }

        // 오디오 입력 설정
        let inputNode: AVAudioInputNode = audioEngine.inputNode
        let recordingFormat: AVAudioFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // 오디오 엔진 시작
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecognizing = true
        } catch {
            cleanup()
            throw SpeechRecognitionError.audioEngineError
        }
    }

    func stopRecognition() {
        // 오디오 엔진 중지
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)

        // 인식 요청 종료
        recognitionRequest?.endAudio()

        // 상태 업데이트
        isRecognizing = false

        // 정리
        cleanup()
    }

    // MARK: - Private Methods

    /// 인식 결과 처리
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) {
        if let error = error {
            // 에러 발생 시 중지
            let nsError: NSError = error as NSError

            // 사용자가 중지한 경우는 에러로 처리하지 않음
            if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 216 {
                return
            }

            stopRecognition()
            return
        }

        guard let result = result else { return }

        // 세그먼트 변환
        let segments: [SpeechSegment] = result.bestTranscription.segments.map { segment in
            SpeechSegment(
                text: segment.substring,
                confidence: segment.confidence,
                timestamp: segment.timestamp,
                duration: segment.duration
            )
        }

        // 전체 confidence 계산
        let overallConfidence: Float
        if segments.isEmpty {
            overallConfidence = 0.0
        } else {
            overallConfidence = segments.reduce(0) { $0 + $1.confidence } / Float(segments.count)
        }

        // 결과 생성
        let recognitionResult: SpeechRecognitionResult = SpeechRecognitionResult(
            text: result.bestTranscription.formattedString,
            isFinal: result.isFinal,
            segments: segments,
            confidence: overallConfidence
        )

        // AsyncStream으로 결과 전달
        continuation?.yield(recognitionResult)

        // 최종 결과면 종료
        if result.isFinal {
            continuation?.finish()
            stopRecognition()
        }
    }

    /// 권한 상태 업데이트
    private func updateAuthorizationStatus() {
        let status: SFSpeechRecognizerAuthorizationStatus = SFSpeechRecognizer.authorizationStatus()
        authorizationStatus = mapAuthorizationStatus(status)
    }

    /// SFSpeechRecognizerAuthorizationStatus를 SpeechAuthorizationStatus로 변환
    private func mapAuthorizationStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> SpeechAuthorizationStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        @unknown default:
            return .denied
        }
    }

    /// 리소스 정리
    private func cleanup() {
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine = nil

        // 오디오 세션 비활성화
        try? audioSession.deactivate()
    }
}
