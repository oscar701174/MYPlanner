//
//  ScheduleView.swift
//  MYPlanner
//
//  Schedule tab - calendar and schedule input form
//

import SwiftUI

struct ScheduleView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Navigation Header
                DateIndicatorView(dateType: .month)
                    .padding(.vertical, 8)

                // Calendar Grid
                CalendarView()

                Divider()
                    .padding(.vertical, 16)

                // Schedule Input Form
                ScheduleInputView()

                Spacer()
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ScheduleView()
        .environment(CalendarViewModel())
        .modelContainer(PreviewData.container)
}
