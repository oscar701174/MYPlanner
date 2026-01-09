//
//  MyWordsView.swift
//  MYPlanner
//
//  My Words tab - English expression learning with TTS and speech recognition
//

import SwiftUI

struct MyWordsView: View {
    @State private var expressions: [Expression] = PreviewData.expressions

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Placeholder for expression list
                Text("My Words View")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
            }
            .navigationTitle("My Words")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MyWordsView()
}
