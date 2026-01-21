//
//  SyllableService.swift
//  MYPlanner
//
//  Syllable separation service
//  Converts phoneme arrays into syllable structures with spelling
//

import Foundation

// MARK: - Syllable Structure

struct Syllable {
    var phonemes: [Phoneme]
    var stress: Int?
    var spelling: String

    var isPrimaryStress: Bool {
        stress == 1
    }

    var isSecondaryStress: Bool {
        stress == 2
    }

    init(phonemes: [Phoneme] = [], stress: Int? = nil, spelling: String = "") {
        self.phonemes = phonemes
        self.stress = stress
        self.spelling = spelling
    }
}

// MARK: - Syllable Service

class SyllableService {

    // MARK: - Singleton

    static let shared: SyllableService = SyllableService()

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Convert phonemes into syllables with spelling
    /// - Parameters:
    ///   - phonemes: Array of phonemes from CMU Dictionary
    ///   - word: Original word for spelling mapping
    /// - Returns: Array of syllables
    func syllabify(phonemes: [Phoneme], word: String) -> [Syllable] {
        // Edge case: empty phonemes
        guard !phonemes.isEmpty else {
            return [Syllable(spelling: word)]
        }

        // Step 1: Split by vowels (each vowel marks a syllable nucleus)
        var syllables: [Syllable] = []
        var currentSyllable: Syllable = Syllable()

        for phoneme: Phoneme in phonemes {
            currentSyllable.phonemes.append(phoneme)

            if phoneme.isVowel {
                currentSyllable.stress = phoneme.stress
                syllables.append(currentSyllable)
                currentSyllable = Syllable()
            }
        }

        // Handle trailing consonants (attach to last syllable)
        if !currentSyllable.phonemes.isEmpty {
            if var lastSyllable: Syllable = syllables.popLast() {
                lastSyllable.phonemes.append(contentsOf: currentSyllable.phonemes)
                syllables.append(lastSyllable)
            } else {
                // No vowels found - treat entire word as one syllable
                currentSyllable.spelling = word
                return [currentSyllable]
            }
        }

        // Step 2: Map spelling to syllables
        return mapSpelling(syllables: syllables, word: word)
    }

    // MARK: - Private Methods

    /// Map word spelling to syllable structures using phoneme ratio
    private func mapSpelling(syllables: [Syllable], word: String) -> [Syllable] {
        var result: [Syllable] = syllables
        let chars: [Character] = Array(word.lowercased())
        let syllableCount: Int = syllables.count

        // Single syllable - entire word
        if syllableCount == 1 {
            result[0].spelling = word
            return result
        }

        // Calculate total phonemes and character-to-phoneme ratio
        let totalPhonemes: Int = syllables.reduce(0) { $0 + $1.phonemes.count }
        let charsPerPhoneme: Double = Double(chars.count) / Double(totalPhonemes)

        var startIndex: Int = 0

        for i: Int in 0..<syllableCount {
            let isLast: Bool = (i == syllableCount - 1)

            if isLast {
                // Last syllable gets remaining characters
                let spelling: String = String(chars[startIndex...])
                result[i].spelling = spelling
            } else {
                // Calculate end based on phoneme count ratio
                let phonemeCount: Int = result[i].phonemes.count
                let suggestedLength: Int = Int(round(Double(phonemeCount) * charsPerPhoneme))
                let suggestedEnd: Int = startIndex + max(suggestedLength, 1)

                // Adjust boundary to fall after vowel when possible
                let adjustedEnd: Int = adjustSyllableBoundary(
                    chars: chars,
                    start: startIndex,
                    suggestedEnd: suggestedEnd,
                    remainingSyllables: syllableCount - i
                )

                let endIndex: Int = min(adjustedEnd, chars.count - 1)
                let spelling: String = String(chars[startIndex..<endIndex])
                result[i].spelling = spelling
                startIndex = endIndex
            }
        }

        return result
    }

    /// Adjust syllable boundary to fall after a vowel when possible
    private func adjustSyllableBoundary(chars: [Character], start: Int, suggestedEnd: Int, remainingSyllables: Int) -> Int {
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]

        // Ensure minimum characters remain for subsequent syllables
        let maxEnd: Int = chars.count - (remainingSyllables - 1)
        let clampedEnd: Int = min(suggestedEnd, maxEnd)

        // Search for vowel boundary near suggested end
        let searchRange: Int = 2

        // First, check if there's a vowel at or just before the suggested end
        for offset: Int in 0...searchRange {
            let checkIndex: Int = clampedEnd - 1 - offset
            if checkIndex >= start && vowels.contains(chars[checkIndex]) {
                // Found vowel - end after it
                return checkIndex + 1
            }
        }

        // If no vowel found, look ahead
        for offset: Int in 1...searchRange {
            let checkIndex: Int = clampedEnd - 1 + offset
            if checkIndex < maxEnd && vowels.contains(chars[checkIndex]) {
                return checkIndex + 1
            }
        }

        // Fallback to suggested end
        return max(start + 1, min(clampedEnd, maxEnd))
    }
}
