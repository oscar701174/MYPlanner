//
//  ProsodyLabel.swift
//  MYPlanner
//
//  Prosody visualization component with full sentence-level features
//  - Stress levels (primary/secondary/none)
//  - Thought group boundaries (/)
//  - Linking markers (‿)
//  - Function word reduction (‹tə›)
//

import SwiftUI

struct ProsodyLabel: View {
    let prosody: String

    // MARK: - Style Constants

    private enum Style {
        // Stress styles
        enum Stress {
            case primary, secondary, none

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

        // Function word style
        static let functionWordColor: Color = Color(red: 0.6, green: 0.6, blue: 0.65)
        static let functionWordSize: CGFloat = 12
        static let functionWordWeight: Font.Weight = .light

        // Thought group separator style
        static let separatorColor: Color = Color(red: 0.3, green: 0.5, blue: 0.8)
        static let separatorSize: CGFloat = 16

        // Linking marker style
        static let linkingColor: Color = Color(red: 0.4, green: 0.7, blue: 0.4)
        static let linkingSize: CGFloat = 14
    }

    var body: some View {
        Text(attributedProsody)
    }

    // MARK: - Attributed String

    private var attributedProsody: AttributedString {
        var result = AttributedString()
        var index = prosody.startIndex

        while index < prosody.endIndex {
            let char = prosody[index]

            // Check for thought group separator
            if char == "/" {
                var separator = AttributedString(" / ")
                separator.foregroundColor = Style.separatorColor
                separator.font = .system(size: Style.separatorSize, weight: .medium)
                result += separator
                index = prosody.index(after: index)
                continue
            }

            // Check for linking marker
            if char == "‿" {
                var linking = AttributedString("‿")
                linking.foregroundColor = Style.linkingColor
                linking.font = .system(size: Style.linkingSize, weight: .regular)
                result += linking
                index = prosody.index(after: index)
                continue
            }

            // Check for function word markers ‹...›
            if char == "‹" {
                if let endIndex = prosody[index...].firstIndex(of: "›") {
                    let start = prosody.index(after: index)
                    let content = String(prosody[start..<endIndex])
                    var funcWord = AttributedString(content)
                    funcWord.foregroundColor = Style.functionWordColor
                    funcWord.font = .system(size: Style.functionWordSize, weight: Style.functionWordWeight)
                    result += funcWord
                    index = prosody.index(after: endIndex)
                    continue
                }
            }

            // Check for secondary stress markers «...»
            if char == "«" {
                if let endIndex = prosody[index...].firstIndex(of: "»") {
                    let start = prosody.index(after: index)
                    let content = String(prosody[start..<endIndex])
                    var secondary = AttributedString(content)
                    secondary.foregroundColor = Style.Stress.secondary.color
                    secondary.font = .system(size: Style.Stress.secondary.fontSize, weight: Style.Stress.secondary.fontWeight)
                    result += secondary
                    index = prosody.index(after: endIndex)
                    continue
                }
            }

            // Check for syllable with hyphen (word part)
            if char == "-" {
                var hyphen = AttributedString("-")
                hyphen.foregroundColor = Style.Stress.none.color
                hyphen.font = .system(size: Style.Stress.none.fontSize, weight: Style.Stress.none.fontWeight)
                result += hyphen
                index = prosody.index(after: index)
                continue
            }

            // Space
            if char == " " {
                result += AttributedString(" ")
                index = prosody.index(after: index)
                continue
            }

            // Regular text - scan until next special character or space
            var textEnd = index
            var isAllUppercase = true
            var hasLetter = false

            while textEnd < prosody.endIndex {
                let c = prosody[textEnd]
                if c == " " || c == "-" || c == "/" || c == "‿" || c == "‹" || c == "«" || c.isPunctuation {
                    break
                }
                if c.isLetter {
                    hasLetter = true
                    if !c.isUppercase {
                        isAllUppercase = false
                    }
                }
                textEnd = prosody.index(after: textEnd)
            }

            let text = String(prosody[index..<textEnd])

            // Determine stress level
            let stress: Style.Stress
            if hasLetter && isAllUppercase {
                stress = .primary
            } else {
                stress = .none
            }

            var styledText = AttributedString(text)
            styledText.foregroundColor = stress.color
            styledText.font = .system(size: stress.fontSize, weight: stress.fontWeight)
            result += styledText

            index = textEnd
        }

        return result
    }
}

// MARK: - Preview

#Preview("Prosody Examples - Connected Speech") {
    VStack(alignment: .leading, spacing: 20) {
        // Basic - completely connected
        Text("Basic (완전 연결):").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "IamaBOY")

        // With stress
        Text("With Stress:").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "IWANTtəGOtəthəSTORE.")

        // With secondary stress (hyphens only within multi-syllable words)
        Text("Secondary Stress:").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "«im»-POR-tant«pre»-sen-TA-tion")

        // With linking (consonant + vowel)
        Text("Linking (C+V):").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "an‿AP-pleəDAY")

        // With thought groups (ONLY separator)
        Text("Thought Groups (유일한 끊김):").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "IWENTtəthəSTORE / ənBOUGHTsəmMILK")

        // With function word markers
        Text("Function Word Markers:").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "IWANT‹tə›GO‹tə›thəSTORE")

        // Full example
        Text("Full Example:").font(.caption).foregroundColor(.gray)
        ProsodyLabel(prosody: "Thisis‿ən«im»-POR-tant«pre»-sen-TA-tion / ‹ən›weNEED‹tə›pre-PARE")
    }
    .padding()
}
