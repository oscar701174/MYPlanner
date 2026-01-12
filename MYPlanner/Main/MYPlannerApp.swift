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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Schedule.self,
            Expression.self
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
