//
//  ButtonStyles.swift
//  MYPlanner
//
//  Design System - Button Styles
//  Primary (orange accent) and Secondary (gray) styles
//

import SwiftUI

// MARK: - Primary Button Style (Orange Accent)

struct PrimaryButtonStyle: ButtonStyle {
    var isCompact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isCompact ? AppFonts.buttonSmall : AppFonts.button)
            .foregroundColor(AppColors.accentText)
            .padding(.horizontal, isCompact ? 16 : 24)
            .padding(.vertical, isCompact ? 8 : 12)
            .background(AppColors.accent)
            .cornerRadius(isCompact ? 6 : 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style (Gray)

struct SecondaryButtonStyle: ButtonStyle {
    var isCompact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isCompact ? AppFonts.buttonSmall : AppFonts.button)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, isCompact ? 16 : 24)
            .padding(.vertical, isCompact ? 8 : 12)
            .background(AppColors.surface)
            .cornerRadius(isCompact ? 6 : 8)
            .overlay(
                RoundedRectangle(cornerRadius: isCompact ? 6 : 8)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style (듣기/말하기)

struct IconButtonStyle: ButtonStyle {
    var backgroundColor: Color = AppColors.accent
    var foregroundColor: Color = AppColors.accentText

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.buttonSmall)
            .foregroundColor(foregroundColor)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Tag Button Style (카테고리 태그)

struct TagButtonStyle: ButtonStyle {
    var isSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.tag)
            .foregroundColor(isSelected ? AppColors.accent : AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppColors.accentLight : AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.accent : AppColors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static var primaryCompact: PrimaryButtonStyle { PrimaryButtonStyle(isCompact: true) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
    static var secondaryCompact: SecondaryButtonStyle { SecondaryButtonStyle(isCompact: true) }
}

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: IconButtonStyle { IconButtonStyle() }
}

extension ButtonStyle where Self == TagButtonStyle {
    static func tag(isSelected: Bool) -> TagButtonStyle {
        TagButtonStyle(isSelected: isSelected)
    }
}
