
import SwiftUI

enum CalendarType {
    case year
    case month
    case day
}

struct DateIndicatorView: View {
    @Environment(CalendarViewModel.self) var dateHolder
    private var date: CalendarType = .day
    
    init(dateType: CalendarType = .day) {
        self.date = dateType
    }
    
    var selectedDate: String {
        switch date {
        case .year:
            return dateHolder.date.yearString
            
        case .month:
            return dateHolder.date.monthYearString
            
        case .day:
            return dateHolder.date.dayMonthYearString
        }
    }
    
    var body: some View {
        HStack
        {
            Button(action: {previous(date)},
                   label: {
                Image(systemName: "arrowtriangle.left.fill")
                    .foregroundColor(.gray)
            }
            )
            
            Text(selectedDate)
                .font(.system(size: 14, weight: .medium, design: .default))
                .onTapGesture {
                    dateHolder.date = Date()
                }
            
            Button(action: {next(date)},
                   label: {
                Image(systemName: "arrowtriangle.right.fill")
                    .foregroundColor(.gray)
            }
            )
            
        }
    }
    
    
    func previous(_ date: CalendarType) {
        switch date {
        case .year:
            dateHolder.date = dateHolder.date.previousYear
            
        case .month:
            dateHolder.date = dateHolder.date.previousMonth
            
        case .day:
            dateHolder.date = dateHolder.date.previousDay
        }
    }
    
    func next(_ date: CalendarType) {
        switch date {
        case .year:
            dateHolder.date = dateHolder.date.nextYear
            
        case .month:
            dateHolder.date = dateHolder.date.nextMonth
            
        case .day:
            dateHolder.date = dateHolder.date.nextDay
        }
    }
}

#Preview {
    DateIndicatorView()
        .environment(CalendarViewModel())
}
