//
//  Category.swift
//  MYPlanner
//
//  일정 카테고리 정의
//

import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case work = "직장"
    case meeting = "회의"
    case personal = "개인"
    case health = "건강"
    case other = "기타"

    var id: String { rawValue }

    /// 카테고리 아이콘 (SF Symbols)
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .meeting: return "person.3.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    /// 카테고리 표시 색상 (태그용)
    var color: Color {
        switch self {
        case .work: return AppColors.accent
        case .meeting: return Color(hex: "4A90D9")
        case .personal: return Color(hex: "50C878")
        case .health: return Color(hex: "FF6B6B")
        case .other: return AppColors.textSecondary
        }
    }
}
