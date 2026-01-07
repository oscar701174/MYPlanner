//
//  AppColors.swift
//  MYPlanner
//
//  Design System - Color Palette
//  Monochrome minimal with orange accent
//

import SwiftUI

enum AppColors {
    // MARK: - Base Colors (검정/회색 계열)

    /// 전체 배경 - #FFFFFF
    static let background = Color.white

    /// 카드 배경, 입력 필드 - #F5F5F5
    static let surface = Color(hex: "F5F5F5")

    /// 구분선, 테두리 - #E0E0E0
    static let border = Color(hex: "E0E0E0")

    // MARK: - Text Colors

    /// 제목, 본문 - #000000
    static let textPrimary = Color.black

    /// 보조 텍스트, 레이블 - #666666
    static let textSecondary = Color(hex: "666666")

    /// 플레이스홀더, 비활성 - #999999
    static let textTertiary = Color(hex: "999999")

    // MARK: - Accent Colors (오렌지 계열 - 제한적 사용)

    /// CTA 버튼 배경, 선택된 날짜 - #FF8C00
    static let accent = Color(hex: "FF8C00")

    /// 태그 배경, 하이라이트 - #FFF3E0
    static let accentLight = Color(hex: "FFF3E0")

    /// 버튼 텍스트 (오렌지 배경 위)
    static let accentText = Color.white
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
