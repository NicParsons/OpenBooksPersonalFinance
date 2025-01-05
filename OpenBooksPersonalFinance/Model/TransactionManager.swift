import Foundation
import OBFoundation
import SwiftData

@Observable
final class TransactionManager {
	var transactions: [Transaction]
	let context: ModelContext
	let myLogger = OBLog()

	subscript(_ transactionID: Transaction.ID) -> Transaction? {
		return transactions.first(where: { $0.id == transactionID } )
	}

	static var all: FetchDescriptor<Transaction> {
		FetchDescriptor<Transaction>()
	}

	func newID() -> Int {
		let transactionIDs = transactions.map { $0.id }
		if let largest = transactionIDs.max() {
return 1 + largest
		} else {
return 1
		} // if let
	} // func

	func newTransaction() -> Transaction {
		let newID = newID()
		let preferences = AppPreferences()
		let currency = preferences.defaultCurrency
		//TODO: Rather than creating a dummy account for the default account, find a better solution. Consider making sourceAccount and destinationAccount properties of Transaction an optional Account.
		let defaultAccount = Account(id: "00", name: "Select an account", parentAccountID: nil)
			let newTransaction = Transaction(id: newID, currency: currency, sourceAccount: defaultAccount, destinationAccount: defaultAccount)
			transactions.append(newTransaction)
			context.insert(newTransaction)
		myLogger.log("Created new transaction with ID \(newTransaction.id).")
return newTransaction
	} // func

	func deleteSelectedTransactions(_ identifiers: Set<Transaction.ID>) {
			for transactionID in identifiers {
				if let transaction = self[transactionID] {
					delete(transaction)
				} // if let
			} // for loop
	} // func

	func delete(_ transaction: Transaction) {
		transactions.removeAll(where: { $0.id == transaction.id })
		context.delete(transaction)
		myLogger.log("Deleted transaction \(transaction.note) with ID \(transaction.id).")
	}

	func delete(_ transactions: [Transaction]) {
		for transaction in transactions {
			delete(transaction)
		}
	}

	func deleteAllTransactions() {
		myLogger.log("About to delete all transactions.")
		delete(transactions)
		myLogger.log("Deleted all transactions.")
	}

	init(context: ModelContext) {
		self.context = context
		do {
			self.transactions = try context.fetch(TransactionManager.all)
		} catch {
			OBLog().error("Enable to fetch Transaction models from the ModelContext.")
			self.transactions = []
		} // do try catch
	} // init
} // class
