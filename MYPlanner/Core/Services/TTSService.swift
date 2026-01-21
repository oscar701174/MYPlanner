//
//  TTSService.swift
//  MYPlanner
//
//  Step 10: Text-to-Speech Service
//  Uses best available voice (Premium/Siri > Enhanced > Default)
//  Supports word-by-word highlighting during speech
//

import AVFoundation
import Observation

@Observable
class TTSService: NSObject {

    // MARK: - Observable Properties

    private(set) var isSpeaking: Bool = false
    private(set) var currentWord: String = ""
    private(set) var currentVoiceName: String = ""

    /// Current speaking range in the original text (for highlighting)
    private(set) var currentRange: Range<String.Index>?

    /// The full text being spoken (for range calculations)
    private(set) var speakingText: String = ""

    // MARK: - Configuration

    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    var pitch: Float = 1.0
    var volume: Float = 1.0
    var language: String = "en-US"

    // MARK: - Private Properties

    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private var currentText: String = ""
    private var bestVoice: AVSpeechSynthesisVoice?

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
        bestVoice = findBestVoice()
        currentVoiceName = bestVoice?.name ?? "Default"
        print("🔊 [TTSService] Selected voice: \(currentVoiceName)")
    }

    // MARK: - Voice Selection

    /// Find the best available English voice (Premium > Enhanced > Default)
    private func findBestVoice() -> AVSpeechSynthesisVoice? {
        let englishVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en-US") }

        // Sort by quality: premium (3) > enhanced (2) > default (1)
        let sortedVoices = englishVoices.sorted { $0.quality.rawValue > $1.quality.rawValue }

        // Debug: Print available voices
        for voice in sortedVoices.prefix(5) {
            print("🔊 [TTSService] Available: \(voice.name) - Quality: \(voice.quality.rawValue)")
        }

        // Return highest quality voice, or fallback to language default
        return sortedVoices.first ?? AVSpeechSynthesisVoice(language: language)
    }

    /// Get list of available English voices for settings
    static var availableVoices: [(name: String, identifier: String, quality: Int)] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
            .map { ($0.name, $0.identifier, $0.quality.rawValue) }
    }

    /// Debug: Print all available voices
    static func printAllVoices() {
        print("🔊 [TTSService] All available English voices:")
        print("=" .padding(toLength: 80, withPad: "=", startingAt: 0))

        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }

        for voice in voices {
            let quality: String
            switch voice.quality {
            case .premium: quality = "⭐ Premium"
            case .enhanced: quality = "✨ Enhanced"
            default: quality = "○ Default"
            }
            let siri = voice.identifier.contains("siri") ? " [SIRI]" : ""
            print("\(quality) | \(voice.name)\(siri)")
            print("         → \(voice.identifier)")
        }
        print("=" .padding(toLength: 80, withPad: "=", startingAt: 0))
        print("Total: \(voices.count) English voices")
    }

    /// Set voice by identifier
    func setVoice(identifier: String) {
        if let voice = AVSpeechSynthesisVoice(identifier: identifier) {
            bestVoice = voice
            currentVoiceName = voice.name
            print("🔊 [TTSService] Changed voice to: \(voice.name)")
        }
    }

    // MARK: - Public Methods

    func speak(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        stop()

        currentText = text
        speakingText = text
        let utterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        currentWord = ""
        currentRange = nil
        speakingText = ""
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func continueSpeaking() {
        synthesizer.continueSpeaking()
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension TTSService: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                          didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                          didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentWord = ""
            self.currentRange = nil
            self.speakingText = ""
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                          didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentWord = ""
            self.currentRange = nil
            self.speakingText = ""
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                          willSpeakRangeOfSpeechString characterRange: NSRange,
                          utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            let text: String = utterance.speechString
            let nsText: NSString = text as NSString
            self.currentWord = nsText.substring(with: characterRange)

            // Convert NSRange to Range<String.Index> for SwiftUI
            if let swiftRange = Range(characterRange, in: text) {
                self.currentRange = swiftRange
            }
        }
    }
}
