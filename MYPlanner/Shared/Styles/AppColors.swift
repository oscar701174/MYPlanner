//
//  AppColors.swift
//  MYPlanner
//
//  Design System - Color Palette
//  Monochrome minimal with orange accent
//  Supports Light and Dark mode
//

import SwiftUI

enum AppColors {
    // MARK: - Base Colors (검정/회색 계열)

    /// 전체 배경 - Light: #FFFFFF, Dark: #000000
    static let background = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    })

    /// 카드 배경, 입력 필드 - Light: #F5F5F5, Dark: #1C1C1E
    static let surface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
            : UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    })

    /// 구분선, 테두리 - Light: #E0E0E0, Dark: #38383A
    static let border = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 56/255, green: 56/255, blue: 58/255, alpha: 1)
            : UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    })

    // MARK: - Text Colors

    /// 제목, 본문 - Light: #000000, Dark: #FFFFFF
    static let textPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })

    /// 보조 텍스트, 레이블 - Light: #666666, Dark: #A0A0A0
    static let textSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1)
            : UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    })

    /// 플레이스홀더, 비활성 - Light: #999999, Dark: #6C6C6C
    static let textTertiary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 108/255, green: 108/255, blue: 108/255, alpha: 1)
            : UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    })

    // MARK: - Accent Colors (오렌지 계열 - 제한적 사용)

    /// CTA 버튼 배경, 선택된 날짜 - #FF8C00 (same for both modes)
    static let accent = Color(hex: "FF8C00")

    /// 태그 배경, 하이라이트 - Light: #FFF3E0, Dark: #3D2E1A
    static let accentLight = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 61/255, green: 46/255, blue: 26/255, alpha: 1)
            : UIColor(red: 255/255, green: 243/255, blue: 224/255, alpha: 1)
    })

    /// 버튼 텍스트 (오렌지 배경 위) - always white
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
