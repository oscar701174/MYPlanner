//
//  SettingsView.swift
//  MYPlanner
//
//  Settings tab - API key configuration and app settings
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Placeholder for settings
                Text("Settings View")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
