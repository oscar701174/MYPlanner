//
//  TTSService.swift
//  MYPlanner
//
//  Step 10: Text-to-Speech Service
//

import AVFoundation
import Combine

class TTSService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var currentWord: String = ""

    // MARK: - Configuration

    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    var pitch: Float = 1.0
    var volume: Float = 1.0
    var language: String = "en-US"

    // MARK: - Private Properties

    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private var currentText: String = ""

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public Methods

    func speak(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        stop()

        currentText = text
        let utterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        currentWord = ""
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
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                          didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentWord = ""
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                          willSpeakRangeOfSpeechString characterRange: NSRange,
                          utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            let text: NSString = utterance.speechString as NSString
            self.currentWord = text.substring(with: characterRange)
        }
    }
}
