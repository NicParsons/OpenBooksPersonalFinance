import SwiftUI
import SwiftData

struct AccountsTableView: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]
	 @State private var selection = Set<Account.ID>()
	@State private var sortOrder = [KeyPathComparator(\Account.id)]

	 var table: some View {
		 Table(accounts, selection: $selection, sortOrder: $sortOrder) {
			 TableColumn("ID", value: \.id) { account in
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
