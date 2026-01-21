//
//  AccentFormatter.swift
//  MYPlanner
//
//  Accent formatting service
//  Converts English text to accent notation with CONNECTED SPEECH
//
//  Key feature: NO SPACES between words (like native speakers hear)
//  Example: "I am a boy" → "IamaBOY"
//  Example: "I have a meeting" → "IhavəəMEET-ing"
//

import Foundation

// MARK: - Accent Formatter

class AccentFormatter {

    // MARK: - Singleton

    static let shared: AccentFormatter = AccentFormatter()

    // MARK: - Properties

    private let cmuService: CMUDictionaryService
    private let syllableService: SyllableService
    private var cache: [String: String] = [:]

    /// Function words - common words that are typically unstressed in sentences
    private let functionWords: Set<String> = [
        // Pronouns
        "i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them",
        "my", "your", "his", "its", "our", "their",
        // Articles
        "a", "an", "the",
        // Be verbs
        "is", "am", "are", "was", "were", "be", "been", "being",
        // Auxiliary verbs
        "do", "does", "did",
        "have", "has", "had",
        "will", "would", "could", "should", "can", "may", "might", "must", "shall",
        // Prepositions
        "to", "for", "of", "in", "on", "at", "by", "with", "from", "into", "onto",
        "about", "after", "before", "between", "through", "during", "under", "over",
        // Conjunctions
        "and", "or", "but", "so", "if", "when", "while", "as", "than", "that", "which",
        // Question words (when not emphasized)
        "how", "what", "who", "where", "why", "when",
        // Other common function words
        "not", "no", "yes", "just", "also", "very", "too", "much", "more", "most",
        "some", "any", "all", "each", "every", "this", "that", "these", "those",
        "there", "here", "then", "now", "still", "already", "yet",
        // Common verbs often unstressed
        "get", "got", "like", "know", "think", "want", "need", "see", "go", "come",
        "take", "make", "give", "let", "put", "say", "tell", "ask", "use", "try"
    ]

    // MARK: - Initialization

    private convenience init() {
        self.init(cmuService: CMUDictionaryService.shared, syllableService: SyllableService.shared)
    }

    init(cmuService: CMUDictionaryService, syllableService: SyllableService) {
        self.cmuService = cmuService
        self.syllableService = syllableService
    }

    /// Test initializer - uses test bundle
    convenience init(testBundle: Bundle) {
        let testCMUService: CMUDictionaryService = CMUDictionaryService(testBundle: testBundle)
        testCMUService.load()
        self.init(cmuService: testCMUService, syllableService: SyllableService.shared)
    }

    // MARK: - Stress Markers

    /// Markers for secondary stress (primary uses UPPERCASE, no stress uses lowercase)
    static let secondaryStressPrefix: String = "«"
    static let secondaryStressSuffix: String = "»"

    // MARK: - Public Methods

    /// Format entire sentence with accent notation (CONNECTED SPEECH - no spaces)
    /// - Parameter sentence: Input sentence
    /// - Returns: Sentence with accent marks, words connected without spaces
    ///   Example: "I have a meeting" → "IhavəMEET-ing"
    func format(_ sentence: String) -> String {
        let words: [String] = sentence.components(separatedBy: " ")
        var result: [String] = []

        for (index, word) in words.enumerated() {
            let formatted: String = formatWord(word, isFirstWord: index == 0)
            result.append(formatted)
        }

        // Join WITHOUT spaces (connected speech)
        return result.joined(separator: "")
    }

    /// Format single word with accent notation
    /// - Parameters:
    ///   - word: Input word
    ///   - isFirstWord: Whether this is the first word in sentence (for capitalization)
    /// - Returns: Word with accent marks
    ///   - Primary stress (1): UPPERCASE (e.g., "PARE")
    ///   - Secondary stress (2): «markers» (e.g., "«pre»")
    ///   - No stress (0): lowercase (e.g., "for")
    func formatWord(_ word: String, isFirstWord: Bool = false) -> String {
        // Separate punctuation
        let (cleanWord, leadingPunct, trailingPunct) = separatePunctuation(word)

        // Skip empty or punctuation-only
        guard !cleanWord.isEmpty else {
            return word
        }

        let lowercased: String = cleanWord.lowercased()

        // Check if it's a function word - return lowercase (no stress marking)
        if functionWords.contains(lowercased) {
            let result: String = isFirstWord ? capitalizeFirst(lowercased) : lowercased
            return leadingPunct + result + trailingPunct
        }

        // Check cache
        let cacheKey: String = lowercased
        if let cached: String = cache[cacheKey] {
            let result: String = isFirstWord ? capitalizeFirst(cached) : cached
            return leadingPunct + result + trailingPunct
        }

        // Lookup in CMU Dictionary
        guard let pronunciation: Pronunciation = cmuService.lookup(cleanWord) else {
            // Word not found - return original
            return word
        }

        // Syllabify
        let syllables: [Syllable] = syllableService.syllabify(
            phonemes: pronunciation.phonemes,
            word: lowercased
        )

        // Format syllables with 3-level stress marking
        let formattedSyllables: [String] = syllables.map { syllable -> String in
            if syllable.isPrimaryStress {
                // Primary stress: UPPERCASE
                return syllable.spelling.uppercased()
            } else if syllable.isSecondaryStress {
                // Secondary stress: «markers»
                return AccentFormatter.secondaryStressPrefix + syllable.spelling.lowercased() + AccentFormatter.secondaryStressSuffix
            } else {
                // No stress: lowercase
                return syllable.spelling.lowercased()
            }
        }

        // Join WITHOUT hyphen (connected speech - syllables flow together)
        // Stress is indicated by UPPERCASE/«markers»/lowercase, not by hyphens
        let formatted: String = formattedSyllables.joined(separator: "")

        // Cache result
        cache[cacheKey] = formatted

        // Apply first word capitalization if needed
        let finalResult: String = isFirstWord ? capitalizeFirst(formatted) : formatted
        return leadingPunct + finalResult + trailingPunct
    }

    /// Clear the cache
    func clearCache() {
        cache.removeAll()
    }

    // MARK: - Private Methods

    /// Separate leading and trailing punctuation from word
    private func separatePunctuation(_ word: String) -> (word: String, leading: String, trailing: String) {
        var leading: String = ""
        var trailing: String = ""
        var core: String = word

        // Extract leading punctuation
        while let first: Character = core.first, first.isPunctuation {
            leading.append(first)
            core.removeFirst()
        }

        // Extract trailing punctuation
        while let last: Character = core.last, last.isPunctuation {
            trailing = String(last) + trailing
            core.removeLast()
        }

        return (core, leading, trailing)
    }

    /// Capitalize first character of a string
    private func capitalizeFirst(_ string: String) -> String {
        guard let first: Character = string.first else {
            return string
        }
        return String(first).uppercased() + String(string.dropFirst())
    }
}
