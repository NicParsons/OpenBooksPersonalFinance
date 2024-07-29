import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
	@Query private var accounts: [Account]
	@State private var parentAccountID: String? = nil
	@State private var newAccountName = ""

    var body: some View {
        NavigationSplitView {
            List {
				ForEach(accounts) { account in
                    NavigationLink {
						HStack {
							Text(account.id)
							Spacer()
							Text(account.name)
						}
                    } label: {
						Text(account.name)
                    }
                }
                .onDelete(perform: deleteAccounts)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addAccount) {
                        Label("Add Account", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an account")
        }
    }

    private func addAccount() {
		let accountManager = AccountManager(context: modelContext, accounts: accounts)
		let newID = accountManager.newID(inParentCategory: parentAccountID)
        withAnimation {
			let newAccount = Account(id: newID, name: newAccountName, parentAccountID: parentAccountID)
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
