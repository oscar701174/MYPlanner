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

    var body: some View {
        Text(title)
            .font(.system(size: AppSizes.FontSize.large, weight: .semibold))
            .foregroundColor(AppColors.accentText)
            .frame(maxWidth: .infinity)
            .frame(height: AppSizes.Height.titleCard)
            .background(AppColors.accent)
            .cornerRadius(AppSizes.Radius.large)
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
