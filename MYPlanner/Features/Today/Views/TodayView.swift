
import SwiftUI

struct TodayView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @State private var schedules: [Schedule] = PreviewData.todaySchedules

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Placeholder for today's schedule list
                Text("Today View")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
            }
            .navigationTitle("Today")
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
    TodayView()
        .environment(CalendarViewModel())
}
