//
//  AccentLabel.swift
//  MYPlanner
//
//  Accent visualization component with 3-level stress display
//  Handles CONNECTED SPEECH format (no spaces, no hyphens between words)
//  Supports word-by-word highlighting during TTS playback
//
//  Input format: "IhavaMEETing" (completely connected)
//  - Primary stress (1): Red #FF3B30, 18pt, Bold (UPPERCASE)
//  - Secondary stress (2): Orange #FF8C00, 16pt, Semibold («markers»)
//  - No stress (0): Gray #8E8E93, 14pt, Regular (lowercase)
//  - Highlighted: Orange underline with thickness based on stress level
//

import SwiftUI

struct AccentLabel: View {
    let accent: String

    /// Original text (for highlighting sync with TTS)
    var originalText: String? = nil

    /// Currently speaking word (from TTSService)
    var highlightedWord: String? = nil

    // MARK: - Constants

    private enum StressStyle {
        case primary    // 주강세 (1)
        case secondary  // 부강세 (2)
        case none       // 무강세 (0)

        var color: Color {
            switch self {
            case .primary:   return Color(red: 1.0, green: 0.231, blue: 0.188)  // #FF3B30
            case .secondary: return Color(red: 1.0, green: 0.549, blue: 0.0)    // #FF8C00
            case .none:      return Color(red: 0.557, green: 0.557, blue: 0.576) // #8E8E93
            }
        }
    }

    /// Base font size for consistent text display
    private let baseFontSize: CGFloat = 15

    var body: some View {
        styledText
    }

    // MARK: - Styled Text using AttributedString

    private var styledText: some View {
        Text(buildAttributedString())
            .tracking(0.3)  // Slight letter spacing for readability
    }

    private func buildAttributedString() -> AttributedString {
        var result: AttributedString = AttributedString()
        let highlightRange: Range<Int>? = calculateHighlightRange()

        var currentIndex: String.Index = accent.startIndex
        var charPosition: Int = 0

        while currentIndex < accent.endIndex {
            let remaining: String = String(accent[currentIndex...])
            let prefix: String = AccentFormatter.secondaryStressPrefix
            let suffix: String = AccentFormatter.secondaryStressSuffix

            // Check for secondary stress markers «»
            if remaining.hasPrefix(prefix),
               let suffixRange = remaining.range(of: suffix) {
                let contentStart: String.Index = remaining.index(remaining.startIndex, offsetBy: prefix.count)
                let contentEnd: String.Index = suffixRange.lowerBound
                let content: String = String(remaining[contentStart..<contentEnd])

                var segment: AttributedString = AttributedString(content)
                segment.foregroundColor = StressStyle.secondary.color
                segment.font = .system(size: baseFontSize, weight: .semibold)

                // Apply underline if highlighted
                if isRangeHighlighted(position: charPosition, length: content.count, highlightRange: highlightRange) {
                    segment.underlineStyle = .thick
                    segment.foregroundColor = Color.orange
                }

                result.append(segment)
                charPosition += content.count

                let advanceBy: Int = prefix.count + content.count + suffix.count
                currentIndex = accent.index(currentIndex, offsetBy: advanceBy)
                continue
            }

            let char: Character = accent[currentIndex]

            if char.isLetter {
                let isUpper: Bool = char.isUppercase
                var text: String = String(char)
                var nextIndex: String.Index = accent.index(after: currentIndex)

                // Group consecutive same-case letters
                while nextIndex < accent.endIndex {
                    let nextChar: Character = accent[nextIndex]
                    if String(nextChar) == prefix { break }
                    if nextChar.isLetter && nextChar.isUppercase != isUpper { break }
                    if nextChar.isLetter || nextChar.isNumber {
                        text.append(nextChar)
                        nextIndex = accent.index(after: nextIndex)
                    } else {
                        break
                    }
                }

                var segment: AttributedString = AttributedString(text)
                let style: StressStyle = isUpper ? .primary : .none
                segment.foregroundColor = style.color

                switch style {
                case .primary:
                    segment.font = .system(size: baseFontSize + 2, weight: .bold)
                case .secondary:
                    segment.font = .system(size: baseFontSize, weight: .semibold)
                case .none:
                    segment.font = .system(size: baseFontSize - 1, weight: .regular)
                }

                // Apply underline if highlighted
                if isRangeHighlighted(position: charPosition, length: text.count, highlightRange: highlightRange) {
                    segment.underlineStyle = .thick
                    segment.foregroundColor = Color.orange
                }

                result.append(segment)
                charPosition += text.count
                currentIndex = nextIndex
            } else {
                // Non-letter characters (punctuation, numbers, etc.)
                var segment: AttributedString = AttributedString(String(char))
                segment.foregroundColor = StressStyle.none.color
                segment.font = .system(size: baseFontSize - 1, weight: .regular)

                if isRangeHighlighted(position: charPosition, length: 1, highlightRange: highlightRange) {
                    segment.underlineStyle = .thick
                    segment.foregroundColor = Color.orange
                }

                result.append(segment)
                charPosition += 1
                currentIndex = accent.index(after: currentIndex)
            }
        }

        return result
    }

    // MARK: - Highlight Calculation

    private func isRangeHighlighted(position: Int, length: Int, highlightRange: Range<Int>?) -> Bool {
        guard let range = highlightRange else { return false }
        let segmentEnd: Int = position + length
        return position < range.upperBound && segmentEnd > range.lowerBound
    }

    /// Calculate the range in accent text that corresponds to the highlighted word
    private func calculateHighlightRange() -> Range<Int>? {
        guard let original = originalText,
              let word = highlightedWord,
              !word.isEmpty else {
            return nil
        }

        // Find the word in original text
        guard let wordRange = original.range(of: word, options: .caseInsensitive) else {
            return nil
        }

        // Count characters before this word (excluding spaces) to map to accent text
        let beforeWord: String = String(original[..<wordRange.lowerBound])
        let cleanBeforeWord: String = beforeWord.replacingOccurrences(of: " ", with: "")

        let startPos: Int = cleanBeforeWord.count
        let wordLength: Int = word.count

        return startPos..<(startPos + wordLength)
    }
}

// MARK: - Preview

#Preview("Connected Speech Examples") {
    VStack(alignment: .leading, spacing: 16) {
        // Basic connected speech (no spaces, no hyphens)
        Text("Basic:").font(.caption).foregroundColor(.gray)
        AccentLabel(accent: "IamaBOY")

        // With multi-syllable words (completely connected)
        Text("With syllables:").font(.caption).foregroundColor(.gray)
        AccentLabel(accent: "IhavaMEETing")

        // Secondary stress
        Text("Secondary stress:").font(.caption).foregroundColor(.gray)
        AccentLabel(accent: "«im»PORtant")

        // Full sentence connected
        Text("Full sentence:").font(.caption).foregroundColor(.gray)
        AccentLabel(accent: "IWANTtoGOtotheSTORE")

        // With highlight (simulating TTS playback)
        Text("With highlight (word: 'meeting'):").font(.caption).foregroundColor(.gray)
        AccentLabel(
            accent: "IhaveaMEETing",
            originalText: "I have a meeting",
            highlightedWord: "meeting"
        )

        // Another highlight example
        Text("With highlight (word: 'have'):").font(.caption).foregroundColor(.gray)
        AccentLabel(
            accent: "IhaveaMEETing",
            originalText: "I have a meeting",
            highlightedWord: "have"
        )

        // Real example
        Text("Real example:").font(.caption).foregroundColor(.gray)
        AccentLabel(accent: "IhaveaMEETingSCHEduledfor3pm")
    }
    .padding()
}
