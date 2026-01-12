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

    var body: some View {
        HStack(spacing: AppSizes.Spacing.small) {
            Image(systemName: category.icon)
                .font(.system(size: AppSizes.FontSize.small))

            Text(category.rawValue)
                .font(.system(size: AppSizes.FontSize.small, weight: .medium))
        }
        .foregroundColor(category.color)
        .padding(.horizontal, AppSizes.Padding.medium)
        .padding(.vertical, AppSizes.Spacing.small)
        .background(category.color.opacity(0.15))
        .cornerRadius(AppSizes.Radius.large)
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
