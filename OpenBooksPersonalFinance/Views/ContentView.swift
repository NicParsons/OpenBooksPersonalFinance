import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
	@Query private var accounts: [Account]
	@State private var parentAccountID: String? = nil
	@State private var selection = Set<Account.ID>()

	var body: some View {
		NavigationSplitView {
			List(selection: $selection) {
				ForEach(accounts.sorted(by: { $0.id < $1.id } )) { account in
					NavigationLink {
						AccountRowView(account: account)
					} label: {
						Text(account.name)
					} // nav link label
				} // ForEach
				.onDelete(perform: deleteAccounts)
#if os(macOS)
				.onDeleteCommand {
					deleteSelectedAccounts(selection)
				}
				#endif
			} // List
#if os(macOS)
			.navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
			.toolbar {
#if os(iOS)
				ToolbarItem(placement: .navigationBarTrailing) {
					EditButton()
				} // toolbar item
#endif
				ToolbarItem {
					Button(action: addAccount) {
						Label("Add Account", systemImage: "plus")
					} // Button label closure
				} // Toolbar item
				/*
				ToolbarItem {
					Button(action: deleteAccounts) {
						Label("Delete Account", systemImage: "minus")
					} // Button
				} // toolbar item
				 */
			} // toolbar
		} detail: {
			Text("Select an account")
		} // nav split view detail closure
	} // body

    private func addAccount() {
		let accountManager = AccountManager(context: modelContext, accounts: accounts)
		let newID = accountManager.newID(inParentCategory: parentAccountID)
        withAnimation {
			let newAccount = Account(id: newID, name: "New Account", parentAccountID: parentAccountID)
modelContext.insert(newAccount)
        }
    }

    private func deleteAccounts(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
				modelContext.delete(accounts[index])
            }
        }
    }

	private func deleteSelectedAccounts(_ identifiers: Set<Account.ID>) {
		let accountManager = AccountManager(context: modelContext, accounts: accounts)
		withAnimation {
			for accountID in identifiers {
				if let account = accountManager[accountID] {
					modelContext.delete(account)
				}
			}
		}
	}

}

/*
#Preview {
    ContentView()
        .modelContainer(for: Account.self, inMemory: true)
}
*/
