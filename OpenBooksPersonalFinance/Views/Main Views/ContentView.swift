import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var context
	@Query private var transactions: [Transaction]
	@SceneStorage("tabSelection") private var tabSelection: String?

	var body: some View {
		TabView(selection: $tabSelection) {
			Tab("Accounts", systemImage: "book.pages", value: "accounts") {
				AccountsTableView()
			} // tab

			Tab("Transactions", systemImage: "book.pages.fill", value: "transactions") {
				TransactionsTableView(transactions: transactions)
			} // Tab
		} // TabView
		.tabViewStyle(.sidebarAdaptable)
#if DEBUG
		.onAppear {
			let transactionManager = TransactionManager(transactions, context: context)
			transactionManager.deleteAllTransactions()
		}
		#endif
	} // body
} // view
