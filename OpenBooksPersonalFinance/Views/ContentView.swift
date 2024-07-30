import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
	@Query private var accounts: [Account]
	@State private var parentAccountID: String? = nil

	var body: some View {
		NavigationSplitView {
			List {
				ForEach(accounts.sorted(by: { $0.id < $1.id } )) { account in
					NavigationLink {
						AccountRowView(account: account)
					} label: {
						Text(account.name)
					} // nav link label
				} // ForEach
				.onDelete(perform: deleteAccounts)
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

    private func deleteAccounts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
				modelContext.delete(accounts[index])
            }
        }
    }
}

/*
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
*/
