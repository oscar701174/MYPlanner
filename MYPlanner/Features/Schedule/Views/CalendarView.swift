import SwiftUI

struct CalendarView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.calendar) var calendar
    private var dateSelected:Date {
        calendarViewModel.date
    }
    
    var weekList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(weekList, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: 60, maxHeight: 60)
                    .background(Color.gray.opacity(0.3))
            }
            
            ForEach(Array(dateSelected.calendarGridDates().enumerated()), id: \.offset) { index, date in
                if let date = date {
                    Text("\(date.day)")
                        .frame(maxWidth: 60, maxHeight: 60)
                        .background(Color.gray.opacity(0.3))
                } else {
                    // 첫째 날 앞의 빈 칸
                    Text("")
                        .frame(maxWidth: 60, maxHeight: 60)
                }
            }
        }
        
    } // body
}

#Preview {
    CalendarView()
        .environment(CalendarViewModel())
}
