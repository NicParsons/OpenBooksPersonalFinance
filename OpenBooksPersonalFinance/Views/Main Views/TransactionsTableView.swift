import SwiftUI
import OBFoundation

struct TransactionsTableView: View {
	@Environment(\.modelContext) var context
	@State var transactions: [Transaction]
	@State private var selection = Set<Transaction.ID>()
	@State private var sortOrder: [KeyPathComparator<Transaction>] = [
		KeyPathComparator(\Transaction.date, order: .reverse),
		KeyPathComparator(\Transaction.id, order: .reverse)
	]
	@State private var inspectorISVisible = true
	let navigationTitle = "Transactions"

	var table: some View {
		Table(orderedTransactions, selection: $selection, sortOrder: $sortOrder) {
			TableColumn("Date", value: \.date) { transaction in
				// the following won't work because it requires a binding
				// DatePicker("Date", selection: transaction.date, displayedComponents: .date)
				// so this is a placeholder
				Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
			} // column

			TableColumn("Description", value: \.note) { transaction in
				// won't work because expects binding
				// TextField("Description", text: transaction.note, prompt: Text("Describe the transaction"))
				// placeholder
				Text(transaction.note)
			}

			// display amount
			TableColumn("Amount", value: \.displayAmount) { transaction in
				Text(transaction.displayAmount, format: .number.precision(.fractionLength(2)))
		} // column

					 TableColumn("Currency", value: \.foreignCurrency) { transaction in
					Text(transaction.foreignCurrency.rawValue.uppercased())
				} // column

//TODO: add local amount

			TableColumn("Source Account", value: \.sourceAccount) { transaction in
				let sourceAccountBinding = Binding(
					get: { transaction.sourceAccount },
					set: { transaction.sourceAccount = $0 }
				)
				AccountPicker(selected: sourceAccountBinding, title: "Source")
					.hideLabel(true)
			} // column

					 TableColumn("Destination Account", value: \.destinationAccount) { transaction in
						 let destinationAccountBinding = Binding(
							get: { transaction.destinationAccount },
							set: { transaction.destinationAccount = $0 }
						 )
						 AccountPicker(selected: destinationAccountBinding, title: "Destination")
							 .hideLabel(true)
					 } // column

		} // Table
	} // var

    var body: some View {
		NavigationStack {
			table
			#if os(macOS)
				.onDeleteCommand {
					deleteSelectedTransactions(selection)
				} // on delete
			#endif

				.inspector(isPresented: $inspectorISVisible) {
					if let selectedTransactionID = selection.first {
						let selectedTransaction: Binding<Transaction> = Binding(
							// warning: force unwrap
							// should be safe as the transaction with matching ID must exist else it could not be selected
							get: { transactions.first(where: { $0.id == selectedTransactionID } )! },
							set: {
								// warning: force unwrap
								let index = transactions.firstIndex(where: { $0.id == selectedTransactionID })!
								transactions[index] = $0
							} // setter
						) // binding var

						TransactionDetailView(transaction: selectedTransaction, visible: $inspectorISVisible)
					} // if let
				} // Inspector

		} // NavStack
		.navigationTitle(Text(navigationTitle))

		.toolbar {
			ToolbarItem {
				Button(action: addTransaction) {
					Label("Add transaction", systemImage: "plus")
				} // button
			} // toolbar item

			ToolbarItem {
				Button(action: { deleteSelectedTransactions(selection) } ) {
					Label("Delete transaction", systemImage: "minus")
				} // button
			} // toolbar item
		} // toolbar

    } // body
} // View

extension TransactionsTableView {
	var orderedTransactions: [Transaction] {
		return transactions
			.sorted(by: { $0.date > $1.date } )
	}

	private func addTransaction() {
		let manager = TransactionManager(transactions)
		let newID = manager.newID()
		let preferences = AppPreferences()
		let currency = preferences.defaultCurrency
		let defaultAccount = Account(id: "00", name: "Select an account", parentAccountID: nil)

		withAnimation {
			let newTransaction = Transaction(id: newID, currency: currency, sourceAccount: defaultAccount, destinationAccount: defaultAccount)
			transactions.append(newTransaction)
			context.insert(newTransaction)
			selection.removeAll()
			selection.insert(newTransaction.id)
			inspectorISVisible = true
		} // animation
	} // func

	private func deleteTransactions(at offsets: IndexSet) {
		withAnimation {
			for index in offsets {
				context.delete(transactions[index])
			} // for loop
		} // animation
	} // func

	private func deleteSelectedTransactions(_ identifiers: Set<Transaction.ID>) {
		let manager = TransactionManager(transactions)
		withAnimation {
			for transactionID in identifiers {
				if let transaction = manager[transactionID] {
					context.delete(transaction)
				} // if let
			} // for loop
		} // animation
	} // func
} // extension
