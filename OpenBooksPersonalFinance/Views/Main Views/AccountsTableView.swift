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
			 TableColumn("Hidden") { account in
				 AccountHiddenColumnView(account: account)
			 }
		 } // Table
	 } // var

    var body: some View {
		NavigationView {
			table
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
						.keyboardShortcut("n", modifiers: [.command])
					} // Toolbar item
				ToolbarItem {
					Button(action: { deleteSelectedAccounts(selection) } ) {
						Label("Delete Account", systemImage: "minus")
					} // button label closure
				} // toolbar item
			} // toolbar
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
