//
//  AppSizes.swift
//  MYPlanner
//
//  Design System - Sizes & Layout Constants
//  Centralized design values from Figma
//

import SwiftUI

enum AppSizes {
    // MARK: - Padding

    enum Padding {
        static let horizontal: CGFloat = 16
        static let vertical: CGFloat = 12
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    // MARK: - Spacing

    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
    }

    // MARK: - Corner Radius

    enum Radius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let pill: CGFloat = 14
        static let circle: CGFloat = 16
    }

    // MARK: - Font Sizes

    enum FontSize {
        static let small: CGFloat = 12
        static let body: CGFloat = 14
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let title: CGFloat = 24
    }

    // MARK: - Component Heights

    enum Height {
        static let button: CGFloat = 32
        static let buttonLarge: CGFloat = 44
        static let buttonSave: CGFloat = 47
        static let tag: CGFloat = 28
        static let card: CGFloat = 68
        static let cardLarge: CGFloat = 139
        static let titleCard: CGFloat = 42
        static let navBar: CGFloat = 44
        static let calendarCell: CGFloat = 43
        static let dateIndicator: CGFloat = 40
        static let input: CGFloat = 44
    }

    // MARK: - Component Widths

    enum Width {
        static let buttonSmall: CGFloat = 32
        static let buttonSave: CGFloat = 200
        static let selectedCircle: CGFloat = 32
        static let eventDot: CGFloat = 6
    }

    // MARK: - Border

    enum Border {
        static let width: CGFloat = 1
    }
}
