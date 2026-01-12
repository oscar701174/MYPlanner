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
                ScheduleInputView { title, category in
                    // TODO: Save to SwiftData
                    print("Save schedule: \(title) - \(category.rawValue)")
                }

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
}
