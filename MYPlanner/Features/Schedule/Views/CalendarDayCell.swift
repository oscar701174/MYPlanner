
import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvent: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    // Selected date background circle
                    if isSelected {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: AppSizes.Width.selectedCircle, height: AppSizes.Width.selectedCircle)
                    }

                    // Day number
                    Text("\(date.day)")
                        .font(.system(size: AppSizes.FontSize.medium, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(dayTextColor)
                }
                .frame(width: AppSizes.Width.selectedCircle, height: AppSizes.Width.selectedCircle)

                // Event indicator dot
                Circle()
                    .fill(hasEvent ? AppColors.accent : Color.clear)
                    .frame(width: AppSizes.Width.eventDot, height: AppSizes.Width.eventDot)
            }
        }
        .buttonStyle(.plain)
        .frame(width: AppSizes.Height.calendarCell, height: AppSizes.Height.calendarCell)
    }

    // MARK: - Computed Properties

    private var dayTextColor: Color {
        if isSelected {
            return AppColors.accentText // white on orange
        }
        return AppColors.textPrimary // black
    }
}

// MARK: - Preview

#Preview("Selected with Event") {
    CalendarDayCell(
        date: Date(),
        isSelected: true,
        hasEvent: true,
        onTap: {}
    )
}

#Preview("Normal with Event") {
    CalendarDayCell(
        date: Date(),
        isSelected: false,
        hasEvent: true,
        onTap: {}
    )
}

#Preview("Normal without Event") {
    CalendarDayCell(
        date: Date(),
        isSelected: false,
        hasEvent: false,
        onTap: {}
    )
}

#Preview("Calendar Row") {
    HStack(spacing: 8) {
        ForEach(1...7, id: \.self) { day in
            CalendarDayCell(
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: day))!,
                isSelected: day == 5,
                hasEvent: [2, 5, 7].contains(day),
                onTap: {}
            )
        }
    }
    .padding()
}
