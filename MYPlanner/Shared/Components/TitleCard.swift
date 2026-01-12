//
//  TitleCard.swift
//  MYPlanner
//
//  Title card component matching Figma design
//  - Orange background with white text
//  - Used for displaying schedule title in MyWords view
//

import SwiftUI

struct TitleCard: View {
    let title: String

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let height: CGFloat = 42
        static let cornerRadius: CGFloat = 12
        static let fontSize: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
    }

    var body: some View {
        Text(title)
            .font(.system(size: Design.fontSize, weight: .semibold))
            .foregroundColor(AppColors.accentText)
            .frame(maxWidth: .infinity)
            .frame(height: Design.height)
            .background(AppColors.accent)
            .cornerRadius(Design.cornerRadius)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        TitleCard(title: "상품 회의 준비하기")
        TitleCard(title: "Meeting Preparation")
    }
    .padding()
}
