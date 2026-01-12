
import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvent: Bool
    let onTap: () -> Void

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let cellSize: CGFloat = 43
        static let selectedCircleSize: CGFloat = 32
        static let eventDotSize: CGFloat = 6
        static let dayFontSize: CGFloat = 16
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    // Selected date background circle
                    if isSelected {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: Design.selectedCircleSize, height: Design.selectedCircleSize)
                    }

                    // Day number
                    Text("\(date.day)")
                        .font(.system(size: Design.dayFontSize, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(dayTextColor)
                }
                .frame(width: Design.selectedCircleSize, height: Design.selectedCircleSize)

                // Event indicator dot
                Circle()
                    .fill(hasEvent ? AppColors.accent : Color.clear)
                    .frame(width: Design.eventDotSize, height: Design.eventDotSize)
            }
        }
        .buttonStyle(.plain)
        .frame(width: Design.cellSize, height: Design.cellSize)
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
