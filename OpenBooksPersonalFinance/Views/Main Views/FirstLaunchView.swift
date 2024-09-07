import SwiftUI
import OBFoundation

struct FirstLaunchView: View {
	@Environment(\.modelContext) private var context
	let preferences = AppPreferences()
	let myLogger = OBLog()

    var body: some View {
		Form {
			CurrencyPicker(selected: preferences.defaultCurrency)
			Text("Choose your local currency which will also act as your default currency.")

			Spacer()

			Button("Done", action: {
				withAnimation {
					preferences.firstLaunch = false
					myLogger.log("Set first launch to false.")
					return
				} // animation
			}) // button
		} // form
		.padding()
    } // body
} // view
