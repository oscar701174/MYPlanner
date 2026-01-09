import SwiftUI

struct ScheduleView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                DateIndicatorView(dateType: .month)
                CalendarView()

                Spacer()
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add schedule action
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
        }
    }
}

#Preview {
    ScheduleView()
        .environment(CalendarViewModel())
}
