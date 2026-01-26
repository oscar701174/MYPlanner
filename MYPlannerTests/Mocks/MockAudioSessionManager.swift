import Foundation
@testable import MYPlanner

// MARK: - Mock Audio Session Manager

/// 테스트용 Mock 오디오 세션 관리자
@MainActor
final class MockAudioSessionManager: AudioSessionManaging {

    // MARK: - Stub Values

    var stubError: AudioSessionError?

    // MARK: - Call Tracking

    var configureForRecordingCallCount: Int = 0
    var configureForPlaybackCallCount: Int = 0
    var deactivateCallCount: Int = 0

    // MARK: - State

    private(set) var isActive: Bool = false

    // MARK: - Protocol Methods

    func configureForRecording() throws {
        configureForRecordingCallCount += 1

        if let error = stubError {
            throw error
        }

        isActive = true
    }

    func configureForPlayback() throws {
        configureForPlaybackCallCount += 1

        if let error = stubError {
            throw error
        }

        isActive = true
    }

    func deactivate() throws {
        deactivateCallCount += 1

        if stubError == .deactivationFailed {
            throw AudioSessionError.deactivationFailed
        }

        isActive = false
    }

    // MARK: - Test Helpers

    /// 상태 초기화
    func reset() {
        configureForRecordingCallCount = 0
        configureForPlaybackCallCount = 0
        deactivateCallCount = 0
        isActive = false
        stubError = nil
    }
}
