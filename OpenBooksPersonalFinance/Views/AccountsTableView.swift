import SwiftUI
import SwiftData

struct AccountsTableView: View {
	@Environment(\.modelContext) private var context
	@Query private var accounts: [Account]

    var body: some View {
		List {
			ForEach(accounts) { account in
				Text(account.name)
			} // ForEach
		} // List
    } // body
} // view

/*
#Preview {
    AccountsTableView()
}
*/


/*
 @State private var selection = Set<Account.ID>()

 var table: some View {
	 Table(accounts, selection: $selection) {
		 TableColumn("Name", value: \.name) { account in
			 TextField(text: account.$name)
		 } // column
	 } // Table
 } // var

 */
