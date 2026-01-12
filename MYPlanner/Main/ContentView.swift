//
//  ContentView.swift
//  MYPlanner
//
//  Main TabView with 4 tabs: Schedule, Today, MyWords, Settings
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .today
    @State private var calendarViewModel = CalendarViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView()
                .environment(calendarViewModel)
                .tabItem {
                    Label(Tab.schedule.title, systemImage: Tab.schedule.icon)
                }
                .tag(Tab.schedule)

            TodayView()
                .environment(calendarViewModel)
                .tabItem {
                    Label(Tab.today.title, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)

            MyWordsTabView()
                .tabItem {
                    Label(Tab.myWords.title, systemImage: Tab.myWords.icon)
                }
                .tag(Tab.myWords)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.accent)
    }
}

// MARK: - Tab Enum

enum Tab: String, CaseIterable {
    case schedule
    case today
    case myWords
    case settings

    var title: String {
        switch self {
        case .schedule: return "Schedule"
        case .today: return "Today"
        case .myWords: return "My Words"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .schedule: return "calendar"
        case .today: return "sun.max.fill"
        case .myWords: return "text.book.closed.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
