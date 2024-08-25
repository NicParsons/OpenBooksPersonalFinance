import Foundation

class TransactionManager {
	let transactions: [Transaction]

	subscript(_ transactionID: Transaction.ID) -> Transaction? {
		return transactions.first(where: { $0.id == transactionID } )
	}

	func newID() -> Int {
		let transactionIDs = transactions.map { $0.id }
		if let largest = transactionIDs.max() {
return 1 + largest
		} else {
return 1
		} // if let
	} // func

	init(_ transactions: [Transaction]) {
		self.transactions = transactions
	}
} // class
