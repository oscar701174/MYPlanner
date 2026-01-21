//
//  AccentLabel.swift
//  MYPlanner
//
//  Accent visualization component with 3-level stress display
//  - Primary stress (1): Red #FF3B30, 18pt, Bold
//  - Secondary stress (2): Orange #FF8C00, 16pt, Semibold
//  - No stress (0): Gray #8E8E93, 14pt, Regular
//

import SwiftUI

struct AccentLabel: View {
    let accent: String

    // MARK: - Stress Style Constants

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

        var fontSize: CGFloat {
            switch self {
            case .primary:   return 18
            case .secondary: return 16
            case .none:      return 14
            }
        }

        var fontWeight: Font.Weight {
            switch self {
            case .primary:   return .bold
            case .secondary: return .semibold
            case .none:      return .regular
            }
        }
    }

    var body: some View {
        Text(attributedAccent)
    }

    // MARK: - Attributed String

    private var attributedAccent: AttributedString {
        var result = AttributedString()
        let words = accent.split(separator: " ", omittingEmptySubsequences: false)

        for (index, word) in words.enumerated() {
            if index > 0 {
                result += AttributedString(" ")
            }

            let syllables = word.split(separator: "-", omittingEmptySubsequences: false)
            for (syllableIndex, syllable) in syllables.enumerated() {
                if syllableIndex > 0 {
                    var hyphen = AttributedString("-")
                    hyphen.foregroundColor = StressStyle.none.color
                    hyphen.font = .system(size: StressStyle.none.fontSize, weight: StressStyle.none.fontWeight)
                    result += hyphen
                }

                let syllableString = String(syllable)
                let (cleanText, stressType) = parseStressMarkers(syllableString)

                var syllableStr = AttributedString(cleanText)
                syllableStr.foregroundColor = stressType.color
                syllableStr.font = .system(size: stressType.fontSize, weight: stressType.fontWeight)

                result += syllableStr
            }
        }

        return result
    }

    // MARK: - Stress Parsing

    /// Parse stress markers and determine stress type
    /// - Primary stress: ALL UPPERCASE letters
    /// - Secondary stress: «markers» around text
    /// - No stress: lowercase letters
    private func parseStressMarkers(_ syllable: String) -> (text: String, stress: StressStyle) {
        let prefix = AccentFormatter.secondaryStressPrefix
        let suffix = AccentFormatter.secondaryStressSuffix

        // Check for secondary stress markers «»
        if syllable.hasPrefix(prefix) && syllable.hasSuffix(suffix) {
            let startIndex = syllable.index(syllable.startIndex, offsetBy: prefix.count)
            let endIndex = syllable.index(syllable.endIndex, offsetBy: -suffix.count)
            let cleanText = String(syllable[startIndex..<endIndex])
            return (cleanText, .secondary)
        }

        // Check for primary stress (all uppercase letters)
        let letters = syllable.filter { $0.isLetter }
        if !letters.isEmpty && letters.allSatisfy({ $0.isUppercase }) {
            return (syllable, .primary)
        }

        // No stress (lowercase)
        return (syllable, .none)
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        AccentLabel(accent: "«im»-POR-tant")
        AccentLabel(accent: "pre-PARE for the PRO-duct")
        AccentLabel(accent: "«pre»-sen-TA-tion")
        AccentLabel(accent: "MEET-ing")
    }
    .padding()
}
