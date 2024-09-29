import Foundation
import SwiftData
import OBFoundation

@Model
class Account: Identifiable, Equatable, Comparable {
	@Attribute(.unique) let id: String
	var name: String
	// parentAccountID should ideally be foreign key to accounts.ID
	var parentAccountID: Account.ID?
	var hidden = false
	var isDeletable = true
	var isNotDeletable: Bool { !isDeletable }

	@Relationship var outgoingTransactions = [Transaction]()
	@Relationship var incomingTransactions = [Transaction]()

	@Relationship(deleteRule: .cascade) var openingBalance: OpeningBalance?

	func totalCredits(from startDate: Date, to endDate: Date) -> Decimal {
		let relevantTransactions = incomingTransactions.filter({
			$0.date >= startDate && $0.date <= endDate
		})
		return relevantTransactions.sum(\.amount)
	}

	func totalDebits(from startDate: Date, to endDate: Date) -> Decimal {
		let relevantTransactions = outgoingTransactions.filter({
			$0.date >= startDate && $0.date <= endDate
		})
		return relevantTransactions.sum(\.amount)
	}

	func movement(from startDate: Date, to endDate: Date) -> Decimal {
		let myLogger = OBLog()
		myLogger.debug("Calculating the movement in \(name) from \(startDate.formatted()) to \(endDate.formatted()).")
		let credits = totalCredits(from: startDate, to: endDate)
		myLogger.debug("The credits were \(credits.formatted()).")
		let debits = totalDebits(from: startDate, to: endDate)
		myLogger.debug("The debits were \(debits.formatted()).")
		return credits - debits
	}

	static func ==(lhs: Account, rhs: Account) -> Bool {
		return lhs.id == rhs.id
	}

	static func <(lhs: Account, rhs: Account) -> Bool {
		return lhs.id < rhs.id
	}

	init(id: String, name: String, parentAccountID: String?, isDeletable: Bool = true) {
		self.id = id
		self.name = name
		self.parentAccountID = parentAccountID
		self.isDeletable = isDeletable
	}
}
