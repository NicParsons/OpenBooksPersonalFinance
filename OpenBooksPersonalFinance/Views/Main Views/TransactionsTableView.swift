import SwiftUI

struct TransactionsTableView: View {
	@State var transactions: [Transaction]
	@State private var selection = Set<Transaction.ID>()
	@State private var sortOrder: [KeyPathComparator<Transaction>] = [
		KeyPathComparator(\Transaction.date, order: .reverse),
		KeyPathComparator(\Transaction.id, order: .reverse)
	]

	var table: some View {
		Table(transactions, selection: $selection, sortOrder: $sortOrder) {
			TableColumn("Date", value: \.date) { transaction in
// the following won't work because it requires a binding
				// DatePicker("Date", selection: transaction.date, displayedComponents: .date)
				// so this is a placeholder
				Text(transaction.date.formatted())
			} // column

			TableColumn("Description", value: \.note) { transaction in
				// won't work because expects binding
				// TextField("Description", text: transaction.note, prompt: Text("Describe the transaction"))
				// placeholder
				Text(transaction.note)
			}
			// amount
			// currency
			// displayAmount
			// currency

			// sourceAccount
			TableColumn("Source Account", value: \.sourceAccount) { transaction in
				var sourceAccountBinding = Binding(
					get: { transaction.sourceAccount },
					set: { transaction.sourceAccount = $0 }
				)
				AccountPicker(selected: sourceAccountBinding, title: "Source")
			} // column

			// destination account
		} // Table
	} // var

    var body: some View {
table
    }
}
