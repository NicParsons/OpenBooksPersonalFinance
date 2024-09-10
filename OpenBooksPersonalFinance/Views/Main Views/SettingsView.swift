import SwiftUI
import OBFoundation

struct SettingsView: View {
	@State private var preferences = AppPreferences()
	let myLogger = OBLog()

	var body: some View {
		VStack {
			Form {
				CurrencyPicker(selected: $preferences.defaultCurrency)
					.onChange(of: preferences.defaultCurrency) {
						myLogger.log("Default currency updated to \(preferences.defaultCurrency.rawValue.uppercased()).")
					}
				Text("Choose your local currency which will also act as your default currency.")
			} // form
			.navigationTitle("Settings")
		} // VStack
    } // body
} // view
