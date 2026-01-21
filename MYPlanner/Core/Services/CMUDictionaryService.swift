//
//  CMUDictionaryService.swift
//  MYPlanner
//
//  CMU Dictionary parsing and lookup service
//  Provides phoneme and stress information for English words
//

import Foundation

// MARK: - Data Structures

/// Phoneme information
struct Phoneme: Equatable {
    let symbol: String      // "IH", "EH", "M", etc.
    let stress: Int?        // 0, 1, 2 (consonants have nil)

    var isVowel: Bool {
        stress != nil       // Only vowels have stress markers
    }
}

/// Word pronunciation information
struct Pronunciation {
    let word: String
    let phonemes: [Phoneme]

    /// Primary stress position (0-based index)
    var primaryStressIndex: Int? {
        phonemes.firstIndex { $0.stress == 1 }
    }

    /// Vowel count (approximate syllable count)
    var syllableCount: Int {
        phonemes.filter { $0.isVowel }.count
    }
}

// MARK: - CMU Dictionary Service

class CMUDictionaryService {

    // MARK: - Singleton

    static let shared: CMUDictionaryService = CMUDictionaryService()

    // MARK: - Properties

    private var dictionary: [String: [Phoneme]] = [:]
    private(set) var isLoaded: Bool = false
    private let bundle: Bundle

    /// Word count in dictionary
    var wordCount: Int {
        dictionary.count
    }

    // MARK: - Initialization

    private convenience init() {
        self.init(bundle: Bundle.main)
    }

    init(bundle: Bundle) {
        self.bundle = bundle
    }

    /// Test initializer - uses test bundle with cmudict_test.txt
    init(testBundle: Bundle) {
        self.bundle = testBundle
    }

    // MARK: - Public Methods

    /// Load dictionary (automatically called on first use)
    func load() {
        guard !isLoaded else { return }

        // Try test file first (for unit tests), then production file
        let resourceName: String = bundle == Bundle.main ? "cmudict" : "cmudict_test"

        guard let url: URL = bundle.url(forResource: resourceName, withExtension: "txt") else {
            print("[CMUDictionaryService] \(resourceName).txt not found in bundle")
            return
        }

        // Read as Data first, then convert to String
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("[CMUDictionaryService] Failed to read \(resourceName).txt data: \(error.localizedDescription)")
            return
        }

        // Try multiple encodings
        let encodings: [(String.Encoding, String)] = [
            (.utf8, "UTF-8"),
            (.ascii, "ASCII"),
            (.isoLatin1, "ISO-Latin1")
        ]

        var content: String?
        for (encoding, name) in encodings {
            if let decoded: String = String(data: data, encoding: encoding) {
                print("[CMUDictionaryService] Successfully decoded with \(name)")
                content = decoded
                break
            }
        }

        guard let content: String = content else {
            print("[CMUDictionaryService] Failed to decode \(resourceName).txt with any encoding")
            return
        }

        let lines: [String] = content.components(separatedBy: .newlines)

        for line: String in lines {
            // Skip comments and empty lines
            guard !line.isEmpty, !line.hasPrefix(";;;") else { continue }

            // Parse "PREPARE  P R IH0 P EH1 R"
            // Split by double space
            let parts: [String] = line.components(separatedBy: "  ")
            guard parts.count >= 2 else { continue }

            // Extract word (remove variant number: "THE(2)" → "THE")
            let wordPart: String = parts[0]
            let word: String = wordPart.components(separatedBy: "(")[0]

            // Skip if word already registered (use first pronunciation only)
            guard dictionary[word] == nil else { continue }

            // Parse phonemes
            let phonemeString: String = parts[1]
            let phonemes: [Phoneme] = parsePhonemes(phonemeString)

            dictionary[word] = phonemes
        }

        isLoaded = true
        print("[CMUDictionaryService] Loaded \(dictionary.count) words")
    }

    /// Lookup phoneme information for a word
    func lookup(_ word: String) -> Pronunciation? {
        // Auto-load on first use
        if !isLoaded {
            load()
        }

        let normalized: String = word.uppercased()
            .trimmingCharacters(in: .punctuationCharacters)

        guard let phonemes: [Phoneme] = dictionary[normalized] else {
            return nil
        }

        return Pronunciation(word: word, phonemes: phonemes)
    }

    /// Check if word exists in dictionary
    func contains(_ word: String) -> Bool {
        // Auto-load on first use
        if !isLoaded {
            load()
        }

        let normalized: String = word.uppercased()
            .trimmingCharacters(in: .punctuationCharacters)
        return dictionary[normalized] != nil
    }

    // MARK: - Private Methods

    private func parsePhonemes(_ string: String) -> [Phoneme] {
        string
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .map { symbol -> Phoneme in
                // "IH0" → symbol: "IH", stress: 0
                // "M" → symbol: "M", stress: nil
                if let lastChar: Character = symbol.last,
                   let stress: Int = Int(String(lastChar)) {
                    let base: String = String(symbol.dropLast())
                    return Phoneme(symbol: base, stress: stress)
                } else {
                    return Phoneme(symbol: symbol, stress: nil)
                }
            }
    }
}

// MARK: - CharacterSet Extension

private extension CharacterSet {
    static let punctuationCharacters: CharacterSet = CharacterSet(charactersIn: ".,!?;:'\"()-")
}
