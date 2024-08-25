import SwiftUI
import SwiftData

struct AccountPicker: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]
	@Binding var selected: Account
	var title = "Account"

    var body: some View {
		Picker(title, selection: $selected) {
			ForEach(childAccounts) { account in
				Text(account.name).tag(account)
			} // ForEach
		} // Picker
    } // body
} // View

extension AccountPicker {
	var childAccounts: [Account] {
		let manager = AccountManager(context: context, accounts: accounts)
		let children = manager.allChildAccounts()
		return children
	} // var
} // extension
