import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var context
	@Query private var transactions: [Transaction]

	var body: some View {
		TabView {
			Tab("Accounts", systemImage: "book.pages") {
				AccountsTableView()
			} // tab

			Tab("Transactions", systemImage: "book.pages.fill") {
				TransactionsTableView(transactions: transactions)
			} // Tab
		} // TabView
		.tabViewStyle(.sidebarAdaptable)
	} // body
} // view
