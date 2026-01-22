//
//  ProsodyFormatter.swift
//  MYPlanner
//
//  Sentence-level prosody formatting service
//  Handles: Thought Groups, Linking, Function Word reduction, Schwa notation
//
//  Key feature: NO SPACES, NO HYPHENS between words (connected speech)
//  Words flow together exactly like native speakers hear them
//
//  Output format example:
//  "I am a boy" → "Iamaboy"
//  "I want to go to the store." → "IWANTtəGOtəthəSTORE."
//  With thought groups: "IWANTtəGO / təthəSTORE."
//

import Foundation

// MARK: - Prosody Markers

enum ProsodyMarker {
    /// Thought group boundary (pause point) - the ONLY separator
    static let thoughtGroupSeparator: String = " / "

    /// Linking marker (consonant + vowel smooth connection)
    static let linking: String = "‿"

    /// Function word marker prefix/suffix for visual distinction
    static let functionWordPrefix: String = "‹"
    static let functionWordSuffix: String = "›"
}

// MARK: - Reduced Pronunciations

/// Common function word reductions (weak forms)
private let reducedPronunciations: [String: String] = [
    // Articles
    "a": "ə",
    "an": "ən",
    "the": "thə",

    // Prepositions
    "to": "tə",
    "for": "fər",
    "of": "əv",
    "from": "frəm",
    "at": "ət",

    // Pronouns
    "you": "yə",
    "your": "yər",
    "her": "hər",
    "him": "əm",
    "them": "thəm",

    // Auxiliaries
    "can": "kən",
    "could": "kəd",
    "would": "wəd",
    "should": "shəd",
    "have": "həv",
    "has": "həz",
    "had": "həd",
    "was": "wəz",
    "were": "wər",
    "are": "ər",
    "am": "əm",

    // Conjunctions
    "and": "ən",
    "or": "ər",
    "but": "bət",
    "that": "thət",
    "than": "thən",

    // Others
    "as": "əz",
    "just": "jəst",
    "some": "səm"
]

// MARK: - Linking Rules

/// Check if linking should occur between two sounds
private func shouldLink(endSound: Character?, startSound: Character?) -> Bool {
    guard let end = endSound, let start = startSound else { return false }

    let consonants: Set<Character> = Set("bcdfghjklmnpqrstvwxyz")
    let vowels: Set<Character> = Set("aeiou")

    // Consonant + Vowel linking (most common)
    // e.g., "an apple" → "an‿apple"
    if consonants.contains(end.lowercased().first ?? " ") &&
       vowels.contains(start.lowercased().first ?? " ") {
        return true
    }

    return false
}

// MARK: - Thought Group Detection

/// Punctuation that indicates thought group boundaries
private let thoughtGroupPunctuation: Set<Character> = [",", ";", ":", "—", "–"]

/// Conjunctions that often mark thought group boundaries
private let thoughtGroupConjunctions: Set<String> = [
    "and", "but", "or", "so", "because", "although", "however",
    "when", "while", "if", "unless", "until", "after", "before"
]

// MARK: - Prosody Formatter

class ProsodyFormatter {

    // MARK: - Singleton

    static let shared: ProsodyFormatter = ProsodyFormatter()

    // MARK: - Properties

    private let accentFormatter: AccentFormatter

    // MARK: - Initialization

    private convenience init() {
        self.init(accentFormatter: AccentFormatter.shared)
    }

    init(accentFormatter: AccentFormatter) {
        self.accentFormatter = accentFormatter
    }

    /// Test initializer
    convenience init(testBundle: Bundle) {
        let testAccentFormatter = AccentFormatter(testBundle: testBundle)
        self.init(accentFormatter: testAccentFormatter)
    }

    // MARK: - Public Methods

    /// Format sentence with full prosody notation (NO SPACES between words)
    /// - Parameters:
    ///   - sentence: Input sentence
    ///   - options: Formatting options
    /// - Returns: Formatted string with prosody markers, words connected without spaces
    ///
    /// Example: "I want to go to the store."
    /// → "I-WANT-tə-GO-tə-thə-STORE."
    func format(_ sentence: String, options: ProsodyOptions = .default) -> String {
        let words = tokenize(sentence)
        var result: [String] = []
        var previousCleanWord: String?
        var needsThoughtGroupBefore = false

        for (index, word) in words.enumerated() {
            let (cleanWord, leadingPunct, trailingPunct) = separatePunctuation(word)

            guard !cleanWord.isEmpty else {
                // Punctuation only - mark for thought group
                if options.showThoughtGroups && isThoughtGroupBoundary(punctuation: word) {
                    needsThoughtGroupBefore = true
                }
                continue
            }

            let isFirstWord = index == 0 || result.isEmpty
            let lowercased = cleanWord.lowercased()

            // Format the word
            var formattedWord: String

            if isFunctionWord(lowercased) {
                // Function word - use reduced form if enabled
                if options.showReducedPronunciation, let reduced = reducedPronunciations[lowercased] {
                    formattedWord = options.showFunctionWordMarkers
                        ? ProsodyMarker.functionWordPrefix + reduced + ProsodyMarker.functionWordSuffix
                        : reduced
                } else {
                    formattedWord = options.showFunctionWordMarkers
                        ? ProsodyMarker.functionWordPrefix + lowercased + ProsodyMarker.functionWordSuffix
                        : lowercased
                }
            } else {
                // Content word - use accent formatting (remove internal hyphens for now, we'll add connectors)
                formattedWord = accentFormatter.formatWord(cleanWord, isFirstWord: isFirstWord)
            }

            // Add punctuation back
            formattedWord = leadingPunct + formattedWord + trailingPunct

            // Determine connector to previous word
            if !result.isEmpty {
                // Check for thought group boundary (from conjunction or punctuation)
                let isThoughtGroupConjunction = options.showThoughtGroups && thoughtGroupConjunctions.contains(lowercased)

                if needsThoughtGroupBefore || isThoughtGroupConjunction {
                    // Thought group separator (the ONLY place with spaces)
                    result.append(ProsodyMarker.thoughtGroupSeparator)
                    needsThoughtGroupBefore = false
                } else if options.showLinking,
                          let prevClean = previousCleanWord,
                          shouldLink(endSound: prevClean.last, startSound: cleanWord.first) {
                    // Linking marker for consonant + vowel
                    result.append(ProsodyMarker.linking)
                }
                // else: NO connector - words just flow together (no space, no hyphen)
            }

            result.append(formattedWord)
            previousCleanWord = cleanWord

            // Check for thought group after this word's punctuation
            if options.showThoughtGroups && isThoughtGroupBoundary(punctuation: trailingPunct) {
                needsThoughtGroupBefore = true
            }
        }

        // Join without additional separators (connectors already in result array)
        var output = result.joined()

        // Capitalize first letter if needed
        if let first = output.first, first.isLetter && !first.isUppercase {
            output = first.uppercased() + String(output.dropFirst())
        }

        return output
    }

    /// Format with default prosody (linking + thought groups)
    func formatWithProsody(_ sentence: String) -> String {
        return format(sentence, options: ProsodyOptions(
            showLinking: true,
            showThoughtGroups: true,
            showReducedPronunciation: true,
            showFunctionWordMarkers: false
        ))
    }

    /// Format with full notation (all markers visible)
    func formatWithFullNotation(_ sentence: String) -> String {
        return format(sentence, options: ProsodyOptions(
            showLinking: true,
            showThoughtGroups: true,
            showReducedPronunciation: true,
            showFunctionWordMarkers: true
        ))
    }

    // MARK: - Private Methods

    private func tokenize(_ sentence: String) -> [String] {
        return sentence.components(separatedBy: " ")
    }

    private func separatePunctuation(_ word: String) -> (word: String, leading: String, trailing: String) {
        var leading: String = ""
        var trailing: String = ""
        var core: String = word

        while let first = core.first, first.isPunctuation {
            leading.append(first)
            core.removeFirst()
        }

        while let last = core.last, last.isPunctuation {
            trailing = String(last) + trailing
            core.removeLast()
        }

        return (core, leading, trailing)
    }

    private func isFunctionWord(_ word: String) -> Bool {
        let functionWords: Set<String> = [
            "i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them",
            "my", "your", "his", "its", "our", "their",
            "a", "an", "the",
            "is", "am", "are", "was", "were", "be", "been", "being",
            "do", "does", "did",
            "have", "has", "had",
            "will", "would", "could", "should", "can", "may", "might", "must", "shall",
            "to", "for", "of", "in", "on", "at", "by", "with", "from", "into", "onto",
            "about", "after", "before", "between", "through", "during", "under", "over",
            "and", "or", "but", "so", "if", "when", "while", "as", "than", "that", "which",
            "not", "no", "yes", "just", "also", "very", "too"
        ]
        return functionWords.contains(word.lowercased())
    }

    private func isThoughtGroupBoundary(punctuation: String) -> Bool {
        return punctuation.contains(where: { thoughtGroupPunctuation.contains($0) })
    }
}

// MARK: - Prosody Options

struct ProsodyOptions {
    /// Show linking markers (‿) between connected words
    var showLinking: Bool

    /// Show thought group boundaries (/)
    var showThoughtGroups: Bool

    /// Show reduced pronunciations (to → tə)
    var showReducedPronunciation: Bool

    /// Show function word markers (‹to›)
    var showFunctionWordMarkers: Bool

    static let `default` = ProsodyOptions(
        showLinking: false,
        showThoughtGroups: false,
        showReducedPronunciation: false,
        showFunctionWordMarkers: false
    )

    static let full = ProsodyOptions(
        showLinking: true,
        showThoughtGroups: true,
        showReducedPronunciation: true,
        showFunctionWordMarkers: true
    )
}
