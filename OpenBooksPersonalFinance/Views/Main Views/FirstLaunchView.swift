import SwiftUI
import SwiftData
import OBFoundation

struct FirstLaunchView: View {
	@Environment(\.modelContext) private var context
	@Query var accounts: [Account]
	@Binding var visible: Bool
	@State private var preferences = AppPreferences()
	let myLogger = OBLog()

    var body: some View {
		VStack {
			Form {
				CurrencyPicker(selected: $preferences.defaultCurrency)
				Text("Choose your local currency which will also act as your default currency.")

				Spacer()

				Button("Done", action: {
					withAnimation {
						let manager = AccountManager(context: context, accounts: accounts)
						if manager.createDefaultAccounts() {
							preferences.firstLaunch = false
							myLogger.log("Set first launch to false.")
							visible = false
						}
						return
					} // animation
				}) // button
			} // form
			.padding()
			.navigationTitle("Set Up OpenBooks Personal Finance")
		} // VStack
    } // body
} // view
