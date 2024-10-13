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

	func totalCredits(from startDate: Date?, to endDate: Date?) -> Decimal {
		let predicate: Predicate<Transaction>
		switch (startDate, endDate) {
		case (.some(let startDate), .some(let endDate)):
			predicate = #Predicate<Transaction> { transaction in
				transaction.date >= startDate && transaction.date <= endDate
			}
		case (.none, .some(let endDate)):
			predicate = #Predicate<Transaction> { transaction in
				transaction.date <= endDate
			}
		case (.some(let startDate), .none):
			predicate = #Predicate<Transaction> { transaction in
				transaction.date >= startDate
			}
		case (.none, .none):
			predicate = #Predicate<Transaction> { transaction in
				// just returning true doesn't work as compiler expects value of type Transaction<Bool>
				transaction.date == transaction.date
			}
			} // switch

		//TODO: Add parameters for currency conversion, and including child accounts
		let relevantTransactions: [Transaction]
		do {
			relevantTransactions = try incomingTransactions.filter(predicate)
		} catch {
			relevantTransactions = incomingTransactions
		}

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

	func balance(asAt balanceDate: Date) -> Decimal {
//TODO: Handle currency conversion.
		let startingBalance: Decimal = openingBalance?.amount ?? 0
		//TODO: Get the budget period start date or the first date on which there are transactions in the db.
		let startDate = openingBalance?.date ??  Date.distantPast
		return startingBalance + movement(from: startDate, to: balanceDate)
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
