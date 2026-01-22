import AVFoundation

// MARK: - Audio Session Manager

/// 오디오 세션 관리 구현체
final class AudioSessionManager: AudioSessionManaging {

    // MARK: - Properties

    private let audioSession: AVAudioSession

    private(set) var isActive: Bool = false

    // MARK: - Initialization

    init(audioSession: AVAudioSession = .sharedInstance()) {
        self.audioSession = audioSession
    }

    // MARK: - Public Methods

    func configureForRecording() throws {
        do {
            // 녹음용 카테고리 설정
            try audioSession.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.defaultToSpeaker, .allowBluetooth]
            )

            // 세션 활성화
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            isActive = true
        } catch {
            isActive = false
            throw AudioSessionError.configurationFailed
        }
    }

    func configureForPlayback() throws {
        do {
            // 재생용 카테고리 설정
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.defaultToSpeaker]
            )

            // 세션 활성화
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            isActive = true
        } catch {
            isActive = false
            throw AudioSessionError.configurationFailed
        }
    }

    func deactivate() throws {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            isActive = false
        } catch {
            throw AudioSessionError.deactivationFailed
        }
    }
}
