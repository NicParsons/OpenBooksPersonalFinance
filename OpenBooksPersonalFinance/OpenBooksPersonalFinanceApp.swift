import SwiftUI
import SwiftData
import OBFoundation

@main
struct OpenBooksPersonalFinanceApp: App {
	@State private var firstLaunch = AppPreferences().firstLaunch
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

	#if DEBUG
	init() {
		// AppPreferences().resetFirstLaunch()
	}
	#endif

    var body: some Scene {
        WindowGroup {
			if firstLaunch {
				FirstLaunchView(visible: $firstLaunch)
			} else {
				ContentView()
			}
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

