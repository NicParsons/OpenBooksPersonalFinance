import SwiftUI
import SwiftData
import OBFoundation

struct ContentView: View {
	@Environment(\.modelContext) private var context
	@Query private var transactions: [Transaction]
	@SceneStorage("tabSelection") private var tabSelection: String?

	var body: some View {
		TabView(selection: $tabSelection) {
			Tab("Transactions", systemImage: "book.pages.fill", value: "transactions") {
				TransactionsTableView(transactions: transactions)
			} // Tab

			Tab("Accounts", systemImage: "book.pages", value: "accounts") {
				AccountsTableView()
			} // tab

			#if os(iOS)
			Tab("Settings", systemImage: "gear", value: "settings") {
				SettingsView()
			}
			#endif

#if DEBUG
			Tab("Log", systemImage: "envelope", value: "log") {
				OBLogTableView()
			}
			#endif
					} // TabView
		.tabViewStyle(.sidebarAdaptable)
#if DEBUG
		.onAppear {
			// let transactionManager = TransactionManager(transactions, context: context)
			// transactionManager.deleteAllTransactions()
		}
		#endif
	} // body
} // view
