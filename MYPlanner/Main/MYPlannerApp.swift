//
//  MYPlannerApp.swift
//  MYPlanner
//
//  Main app entry point with SwiftData ModelContainer
//

import SwiftUI
import SwiftData

@main
struct MYPlannerApp: App {

    init() {
        // Pre-load CMU Dictionary at app start for faster first access
        CMUDictionaryService.shared.load()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Schedule.self,
            Expression.self,
            PracticeRecord.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
