//
//  AppFonts.swift
//  MYPlanner
//
//  Design System - Typography
//  Supports Dynamic Type for accessibility
//

import SwiftUI

enum AppFonts {
    // MARK: - Title Styles

    /// 큰 제목 (탭 헤더)
    static let largeTitle = Font.largeTitle.weight(.bold)

    /// 섹션 제목
    static let title = Font.title2.weight(.semibold)

    /// 카드 제목
    static let headline = Font.headline

    // MARK: - Body Styles

    /// 본문 텍스트
    static let body = Font.body

    /// 영어 표현 텍스트
    static let expression = Font.body.weight(.medium)

    /// 악센트 표시 텍스트
    static let accent = Font.subheadline.weight(.regular)

    // MARK: - Caption Styles

    /// 보조 텍스트, 레이블
    static let caption = Font.caption

    /// 태그, 작은 레이블
    static let tag = Font.caption2.weight(.medium)

    // MARK: - Button Styles

    /// 버튼 텍스트
    static let button = Font.body.weight(.semibold)

    /// 작은 버튼 텍스트
    static let buttonSmall = Font.subheadline.weight(.medium)
}

// MARK: - Text Style Modifiers

extension View {
    func textStyle(_ font: Font, color: Color = AppColors.textPrimary) -> some View {
        self
            .font(font)
            .foregroundColor(color)
    }
}
