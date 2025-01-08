import SwiftUI
import SwiftData
import OBFoundation

struct FirstLaunchView: View {
	@Environment(\.modelContext) private var context
	@Query var accounts: [Account]
	@Binding var visible: Bool
	@State private var deleteAllTransactions = false
	@State private var deleteAllAccounts = false
	@State private var preferences = AppPreferences()
	let myLogger = OBLog()

    var body: some View {
		VStack {
			Form {
				CurrencyPicker(selected: $preferences.defaultCurrency)
				Text("Choose your local currency which will also act as your default currency.")

#if DEBUG
				Spacer()

				HStack {
					Button("Delete all accounts") { deleteAllAccounts = true }
						.disabled(deleteAllAccounts == true)
						.alert("Deleting all accounts cannot be undone.", isPresented: $deleteAllAccounts) {
							Button("Confirm delete all accounts", role: .destructive, action: resetAccounts)
							Button("Cancel", role: .cancel) {
								Model(context: context).myLogger.log("Cancel button pressed.")
							}
						}

					Button("Delete all transactions") { deleteAllTransactions = true }
						.disabled(deleteAllTransactions == true)
						.alert("Deleting all transactions cannot be undone", isPresented: $deleteAllTransactions) {
							Button("Confirm delete all transactions", role: .destructive, action: resetTransactions)
							Button("Cancel", role: .cancel) {
								Model(context: context).myLogger.log("Cancel button pressed.")
							}
						}
		} // HStack
		#endif

				Spacer()

				Button("Done", action: {
					let model = Model(context: context)
					withAnimation {
						if model.createDefaultAccounts(withDefaultCurrency: preferences.defaultCurrency) {
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

extension FirstLaunchView {
	func resetAccounts() {
		let model = Model(context: context)
		model.deleteAllAccounts(true)
	}

	func resetTransactions() {
		let model = Model(context: context)
		model.transactionManager.deleteAllTransactions()
	}
}
