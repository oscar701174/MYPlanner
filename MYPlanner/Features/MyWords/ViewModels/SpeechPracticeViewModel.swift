import Foundation

// MARK: - Speech Practice State

/// 발음 연습 상태
enum SpeechPracticeState: Equatable {
    case idle           // 대기 중
    case loading        // 모델 로딩 중 (WhisperKit)
    case recording      // 녹음 중
    case evaluating     // 평가 중
    case result         // 결과 표시
    case error          // 에러 발생
}

// MARK: - Speech Practice ViewModel

/// 발음 연습 ViewModel
@MainActor
@Observable
final class SpeechPracticeViewModel {

    // MARK: - Dependencies

    private var speechRecognizer: SpeechRecognizing
    private let evaluator: PronunciationEvaluating

    // MARK: - Published State

    private(set) var state: SpeechPracticeState = .idle
    private(set) var score: PronunciationScore?
    private(set) var error: SpeechRecognitionError?
    var recognizedText: String = ""
    private(set) var originalText: String = ""
    private(set) var currentEngineType: SpeechRecognitionEngineType = .apple

    // MARK: - Internal

    private var recognitionTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        speechRecognizer: SpeechRecognizing? = nil,
        evaluator: PronunciationEvaluating? = nil,
        engineType: SpeechRecognitionEngineType = .apple
    ) {
        self.currentEngineType = engineType
        self.speechRecognizer = speechRecognizer ?? Self.createRecognizer(for: engineType)
        self.evaluator = evaluator ?? PronunciationEvaluator()
    }

    // MARK: - Engine Selection

    /// 음성 인식 엔진 변경
    func switchEngine(to engineType: SpeechRecognitionEngineType) {
        guard engineType != currentEngineType else { return }

        // 현재 인식 중이면 중지
        if state == .recording {
            stopPractice()
        }

        currentEngineType = engineType
        speechRecognizer = Self.createRecognizer(for: engineType)

        // 상태 초기화
        reset()
    }

    /// 엔진 타입에 맞는 인식기 생성
    private static func createRecognizer(for engineType: SpeechRecognitionEngineType) -> SpeechRecognizing {
        switch engineType {
        case .apple:
            return SpeechRecognizer()
        case .whisper:
            return WhisperRecognizer()
        }
    }

    // MARK: - Public Methods

    /// 권한 확인
    func checkAuthorization() async -> Bool {
        let status: SpeechAuthorizationStatus = speechRecognizer.authorizationStatus

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            let newStatus: SpeechAuthorizationStatus = await speechRecognizer.requestAuthorization()
            return newStatus == .authorized
        case .denied, .restricted:
            return false
        }
    }

    /// 발음 연습 시작
    func startPractice(for text: String) async {
        // 권한 확인
        let isAuthorized: Bool = await checkAuthorization()
        guard isAuthorized else {
            state = .error
            error = .notAuthorized
            return
        }

        // 상태 초기화
        originalText = text
        recognizedText = ""
        score = nil
        error = nil

        // 인식 시작
        do {
            try await speechRecognizer.startRecognition()
            state = .recording

            // 인식 결과 수신
            recognitionTask = Task {
                for await result in speechRecognizer.recognitionResults {
                    await MainActor.run {
                        self.recognizedText = result.text

                        if result.isFinal {
                            self.handleFinalResult(result)
                        }
                    }
                }
            }
        } catch let speechError as SpeechRecognitionError {
            state = .error
            error = speechError
        } catch {
            state = .error
            self.error = .recognitionFailed(error.localizedDescription)
        }
    }

    /// 발음 연습 중지
    func stopPractice() {
        speechRecognizer.stopRecognition()
        recognitionTask?.cancel()
        recognitionTask = nil

        // 인식된 텍스트가 있으면 평가 진행
        if !recognizedText.isEmpty {
            state = .evaluating
            evaluateResult()
        } else {
            state = .idle
        }
    }

    /// 상태 초기화
    func reset() {
        recognitionTask?.cancel()
        recognitionTask = nil
        state = .idle
        score = nil
        error = nil
        recognizedText = ""
        originalText = ""
    }

    // MARK: - Private Methods

    /// 최종 결과 처리
    private func handleFinalResult(_ result: SpeechRecognitionResult) {
        state = .evaluating
        evaluateResult(with: result)
    }

    /// 발음 평가 (인식 결과 사용)
    private func evaluateResult(with result: SpeechRecognitionResult? = nil) {
        let recognitionResult: SpeechRecognitionResult

        if let result = result {
            recognitionResult = result
        } else {
            // 수동 중지 시 현재 텍스트로 결과 생성
            recognitionResult = SpeechRecognitionResult(
                text: recognizedText,
                isFinal: true,
                segments: [],
                confidence: 0.8
            )
        }

        // 비동기 평가
        Task {
            let evaluatedScore: PronunciationScore = evaluator.evaluate(
                recognized: recognitionResult,
                original: originalText
            )

            await MainActor.run {
                self.score = evaluatedScore
                self.state = .result
            }
        }
    }
}
