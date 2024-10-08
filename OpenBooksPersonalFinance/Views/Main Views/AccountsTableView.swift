import SwiftUI
import SwiftData

struct AccountsTableView: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]
	@State private var navigationPath: [Account] = []
	 @State private var selection = Set<Account.ID>()
	@State private var sortOrder: [KeyPathComparator<Account>] = [
		KeyPathComparator(\Account.id, order: .forward),
	]
	@SceneStorage("accountInspectorIsVisible") private var inspectorIsVisible = true

	 var table: some View {
		 Table(relevantAccounts, selection: $selection, sortOrder: $sortOrder) {
			 TableColumn("ID", value: \.id, comparator: IDComparator()) { account in
				 Button(account.id, action: {
					 withAnimation {
						 navigationPath.append(account)
					 }
				 })
			 } // TableColumn
			 TableColumn("Name", value: \.name) { account in
				 AccountNameColumnView(account: account)
			 } // column

			 /* not needed given inspector
			 TableColumn("Hidden") { account in
				 AccountHiddenColumnView(account: account)
			 }
			  */
		 } // Table
	 } // var

    var body: some View {
		NavigationView {
			table
				.onKeyPress(.return, action: {
					if let selectedAccount = firstSelectedAccount {
						withAnimation {
							navigationPath.append(selectedAccount)
						} // animation
					} // if let
					return .handled
				}) // keypress
							#if os(macOS)
				.onDeleteCommand {
					deleteSelectedAccounts(selection)
				} // delete command
			#endif
		} // nav stack
		.navigationTitle(navigationTitle)
			.toolbar {
				ToolbarItem {
					Button(action: {
						withAnimation {
							navigationPath.removeLast()
							return
						}
					}) {
						Label("Back", systemImage: "arrowshape.backward")
					}
					.disabled(navigationPath.isEmpty)
					.keyboardShortcut("[", modifiers: [.command])
				} // toolbar item
					ToolbarItem {
						Button(action: addAccount) {
							Label("Add Account", systemImage: "plus")
						} // Button label closure
						.disabled(parentAccountID == nil)
						.keyboardShortcut("n", modifiers: [.command, .option])
					} // Toolbar item
				ToolbarItem {
					Button(action: { deleteSelectedAccounts(selection) } ) {
						Label("Delete Account", systemImage: "minus")
					} // button label closure
					.disabled(!selectedAccountsAreDeletable || selection.isEmpty)
				} // toolbar item
			} // toolbar

			.inspector(isPresented: $inspectorIsVisible) {
				if let selectedAccount = firstSelectedAccount {
					AccountDetailView(account: selectedAccount, visible: $inspectorIsVisible)
				} else {
					Text("Select an account.")
				}
			} // inspector
    } // body
} // view

struct AccountNameColumnView: View {
	@Bindable var account: Account
	var body: some View {
		TextField("Name", text: $account.name)
			.labelsHidden()
	}
}

struct AccountHiddenColumnView: View {
	@Bindable var account: Account
	var body: some View {
		Toggle("HIdden", isOn: $account.hidden)
			.labelsHidden()
	}
}

struct IDComparator: SortComparator {
	var order: SortOrder = .forward

	func compare(_ lhs: Account.ID, _ rhs: Account.ID) -> ComparisonResult {
		let result: ComparisonResult = lhs.localizedCompare(rhs)
		return order == .forward ? result : result.reversed
	}
}

extension ComparisonResult {
  var reversed: ComparisonResult {
	switch self {
	case .orderedAscending: return .orderedDescending
	case .orderedSame: return .orderedSame
	case .orderedDescending: return .orderedAscending
	}
  }
}

extension AccountsTableView {
	var parentAccountID: Account.ID? {
		return navigationPath.last?.id ?? nil
	}

	var relevantAccounts: [Account] {
		return accounts
			.filter({ $0.parentAccountID == parentAccountID } )
			.sorted(using: sortOrder)
	}

	var selectedAccounts: [Account] {
		return accounts
			.filter({ selection.contains($0.id) })
	}

	var selectedAccountsAreDeletable: Bool {
		var areDeletable = true
		for account in selectedAccounts {
			if !account.isDeletable { areDeletable = false }
		}
		return areDeletable
	}

	var firstSelectedAccount: Account? {
		return selectedAccounts.first
	}

	private var navigationTitle: String {
var title = "Accounts"
		if let parentID = parentAccountID {
			let accountManager = AccountManager(context: context, accounts: accounts)
			if let parentAccount = accountManager[parentID] {
				title += " – " + parentAccount.name
			}
		}
		return title
	}

	private func addAccount() {
		let accountManager = AccountManager(context: context, accounts: accounts)
		let newID = accountManager.newID(inParentCategory: parentAccountID)
		withAnimation {
			let newAccount = Account(id: newID, name: "New Account", parentAccountID: parentAccountID)
			context.insert(newAccount)
		}
	}

	private func deleteAccounts(at offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				context.delete(accounts[index])
			}
		}
	}

	private func deleteSelectedAccounts(_ identifiers: Set<Account.ID>) {
		let accountManager = AccountManager(context: context, accounts: accounts)
		withAnimation {
			for accountID in identifiers {
				if let account = accountManager[accountID] {
					context.delete(account)
				}
			}
		}
	}
}
