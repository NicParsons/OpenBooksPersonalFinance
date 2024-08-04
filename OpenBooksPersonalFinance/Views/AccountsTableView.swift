import SwiftUI
import SwiftData

struct AccountsTableView: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]
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
		accounts.sorted(using: sortOrder)
	}
}
