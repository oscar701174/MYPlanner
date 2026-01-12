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
    var isActive: Bool = false
    var onTap: (() -> Void)?

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let fontSize: CGFloat = 14
        static let height: CGFloat = 32
        static let cornerRadius: CGFloat = 6
        static let horizontalPadding: CGFloat = 10
    }

    var body: some View {
        Button(action: { onTap?() }) {
            Text(type.title)
                .font(.system(size: Design.fontSize))
                .foregroundColor(AppColors.accentText)
                .padding(.horizontal, Design.horizontalPadding)
                .frame(height: Design.height)
                .background(isActive ? AppColors.accent.opacity(0.7) : AppColors.accent)
                .cornerRadius(Design.cornerRadius)
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
