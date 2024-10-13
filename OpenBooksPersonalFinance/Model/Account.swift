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

	func totalTransactions(from startDate: Date?, to endDate: Date?, transactionType: TransactionType) -> Decimal {
		//TODO: Add parameters for currency conversion, and including child accounts
		var relevantTransactions = transactionType == .credit ? incomingTransactions : outgoingTransactions
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

		do {
			relevantTransactions = try relevantTransactions.filter(predicate)
		} catch {
			OBLog().error("Unable to filter relevant \(name) transactions.")
		}

		var total = relevantTransactions.sum(\.amount)
		return total.roundedTo(decimalPlaces: 2)
	}

	func totalCredits(from startDate: Date?, to endDate: Date?) -> Decimal {
		return totalTransactions(from: startDate, to: endDate, transactionType: .credit)
	}

	func totalDebits(from startDate: Date?, to endDate: Date?) -> Decimal {
		return totalTransactions(from: startDate, to: endDate, transactionType: .debit)
	}

	func movement(from startDate: Date?, to endDate: Date?) -> Decimal {
		let myLogger = OBLog()
		myLogger.debug("Calculating the movement in \(name) from \(startDate?.formatted() ?? "the beginning of time") to \(endDate?.formatted() ?? "the end of time").")
		let credits = totalCredits(from: startDate, to: endDate)
		myLogger.debug("The credits were \(credits.formatted()).")
		let debits = totalDebits(from: startDate, to: endDate)
		myLogger.debug("The debits were \(debits.formatted()).")
		var total = credits - debits
		return total.roundedTo(decimalPlaces: 2)
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

enum TransactionType: String, CaseIterable, Codable, RawRepresentable {
	case credit, debit
}
