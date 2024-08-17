import SwiftUI
import SwiftData

struct AccountsTableContainerView: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]
	@State private var navigationPath: [Account] = []

    var body: some View {
		NavigationStack(path: $navigationPath) {
			// AccountsTableView()
			Text("Placeholder")
		} // nav stack
		.navigationTitle(navigationTitle)
    } // body
} // view

extension AccountsTableContainerView {
	var navigationTitle: String {
		var title = "Accounts"
		if let selectedAccount = navigationPath.last {
			title += " – " + selectedAccount.name
		}
		return title
	}
}
