import SwiftUI
import SwiftData

struct AccountsTableView: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]
	@State private var parentAccountID: String? = nil
	 @State private var selection = Set<Account.ID>()
	@State private var sortOrder: [KeyPathComparator<Account>] = [
		KeyPathComparator(\Account.id, order: .forward),
	]

	 var table: some View {
		 Table(sortedAccounts, selection: $selection, sortOrder: $sortOrder) {
			 TableColumn("ID", value: \.id, comparator: IDComparator()) { account in
				 Text(account.id)
			 }
			 TableColumn("Name", value: \.name) { account in
				 AccountNameColumnView(account: account)
			 } // column
			 TableColumn("Hidden") { account in
				 AccountHiddenColumnView(account: account)
			 }
		 } // Table
	 } // var

    var body: some View {
		table
			.onDeleteCommand {
				deleteSelectedAccounts(selection)
			}
			.toolbar {
					ToolbarItem {
						Button(action: addAccount) {
							Label("Add Account", systemImage: "plus")
						} // Button label closure
					} // Toolbar item
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
	var sortedAccounts: [Account] {
		return accounts
			.filter({ $0.parentAccountID == parentAccountID } )
			.sorted(using: sortOrder)
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
