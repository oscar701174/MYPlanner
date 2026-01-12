//
//  TagChip.swift
//  MYPlanner
//
//  Category tag chip component matching Figma design
//  - Accent light background with accent text
//  - Used for displaying schedule categories
//

import SwiftUI

struct TagChip: View {
    let category: Category

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let fontSize: CGFloat = 12
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 4
        static let cornerRadius: CGFloat = 12
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: Design.fontSize))

            Text(category.rawValue)
                .font(.system(size: Design.fontSize, weight: .medium))
        }
        .foregroundColor(category.color)
        .padding(.horizontal, Design.horizontalPadding)
        .padding(.vertical, Design.verticalPadding)
        .background(category.color.opacity(0.15))
        .cornerRadius(Design.cornerRadius)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        ForEach(Category.allCases) { category in
            TagChip(category: category)
        }
    }
    .padding()
}

#Preview("Single Tag") {
    TagChip(category: .work)
}
