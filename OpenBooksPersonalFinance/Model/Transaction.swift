import Foundation
import OBFoundation
import SwiftData

@Model
class Transaction: Identifiable {
	@Attribute(.unique) let id: Int
	var date: Date = Date()
	var note: String = ""

// amount and displayAmount would ideally be custom type Money
	// but SwiftData makes that difficult
	var amount: Decimal
	var localCurrency: Currency
	var displayAmount: Decimal
	var foreignCurrency: Currency

// need to consider whether to do sourceAccount and destinationAccount or do proper journal entries
	var sourceAccount: Account
	var destinationAccount: Account

	var reconciledSource: Bool = false
	var reconciledDestination: Bool = false
	var taxDeduction: Bool = false
	var recurring: Bool = false
	var hidden:Bool = false

	init(id: Int, amount: Decimal, localCurrency: Currency, displayAmount: Decimal, foreignCurrency: Currency, sourceAccount: Account, destinationAccount: Account) {
		self.id = id
		self.amount = amount
		self.localCurrency = localCurrency
		self.displayAmount = displayAmount
		self.foreignCurrency = foreignCurrency
		self.sourceAccount = sourceAccount
		self.destinationAccount = destinationAccount
	}
}
