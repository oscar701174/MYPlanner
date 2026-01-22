import Foundation

// MARK: - Audio Session Managing Protocol

/// 오디오 세션 관리 책임 (SRP: 오직 오디오 세션만)
protocol AudioSessionManaging {
    /// 현재 활성화 상태
    var isActive: Bool { get }

    /// 녹음용 세션 설정
    func configureForRecording() throws

    /// 재생용 세션 설정
    func configureForPlayback() throws

    /// 세션 비활성화
    func deactivate() throws
}

// MARK: - Audio Session Error

/// 오디오 세션 에러
enum AudioSessionError: Error, Equatable, Sendable {
    case configurationFailed
    case activationFailed
    case deactivationFailed

    var localizedDescription: String {
        switch self {
        case .configurationFailed:
            return "Failed to configure audio session."
        case .activationFailed:
            return "Failed to activate audio session."
        case .deactivationFailed:
            return "Failed to deactivate audio session."
        }
    }
}
