//
//  AccentLabel.swift
//  MYPlanner
//
//  Accent visualization component matching Figma design
//  - Displays pronunciation hints like "pre-PARE for the PRO-duct"
//  - Uppercase syllables shown in bold/accent color
//

import SwiftUI

struct AccentLabel: View {
    let accent: String

    var body: some View {
        Text(attributedAccent)
            .font(.system(size: AppSizes.FontSize.body))
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
                    result += AttributedString("-")
                }

                var syllableStr = AttributedString(String(syllable))
                let isStressed = syllable.allSatisfy { $0.isUppercase || !$0.isLetter }
                    && syllable.contains(where: { $0.isUppercase })

                if isStressed {
                    syllableStr.foregroundColor = AppColors.accent
                    syllableStr.font = .system(size: AppSizes.FontSize.body, weight: .bold)
                } else {
                    syllableStr.foregroundColor = AppColors.textSecondary
                    syllableStr.font = .system(size: AppSizes.FontSize.body, weight: .regular)
                }

                result += syllableStr
            }
        }

        return result
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        AccentLabel(accent: "pre-PARE for the PRO-duct")
        AccentLabel(accent: "get REA-dy for the PRO-duct")
        AccentLabel(accent: "MEET-ing")
    }
    .padding()
}
