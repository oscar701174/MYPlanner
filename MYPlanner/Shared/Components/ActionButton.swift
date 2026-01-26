//
//  ActionButton.swift
//  MYPlanner
//
//  Action button component (듣기/말하기) matching Figma design
//  - Orange background with white text
//  - Used for TTS and speech recognition actions
//

import SwiftUI

enum ActionButtonType {
    case listen  // 듣기
    case speak   // 말하기

    var title: String {
        switch self {
        case .listen: return "듣기"
        case .speak: return "말하기"
        }
    }

    var icon: String {
        switch self {
        case .listen: return "speaker.wave.2.fill"
        case .speak: return "mic.fill"
        }
    }
}

struct ActionButton: View {
    let type: ActionButtonType
    let isActive: Bool
    let onTap: (() -> Void)?

    init(type: ActionButtonType, isActive: Bool = false, onTap: (() -> Void)? = nil) {
        self.type = type
        self.isActive = isActive
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            Text(type.title)
                .font(.system(size: AppSizes.FontSize.body))
                .foregroundColor(AppColors.accentText)
                .padding(.horizontal, AppSizes.Padding.medium)
                .frame(height: AppSizes.Height.button)
                .background(isActive ? AppColors.accent.opacity(0.7) : AppColors.accent)
                .cornerRadius(AppSizes.Radius.small)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ActionButton(type: .listen) {
            print("Listen tapped")
        }
        ActionButton(type: .speak) {
            print("Speak tapped")
        }
        ActionButton(type: .listen, isActive: true) {
            print("Active listen")
        }
    }
    .padding()
}
