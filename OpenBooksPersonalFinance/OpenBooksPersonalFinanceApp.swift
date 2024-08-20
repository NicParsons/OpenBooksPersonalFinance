import SwiftUI
import SwiftData
import OBFoundation

@main
struct OpenBooksPersonalFinanceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
			Account.self,
			Transaction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
//
//  OpenBooksPersonalFinanceApp.swift
//  OpenBooksPersonalFinance
//
//  Created by Nicholas Parsons on 6/7/2024.
//

