import Foundation
import OBFoundation
import SwiftData

@Model
class BudgetLineItem {
	var account: Account
	var displayAmount: Decimal
	var currency: Currency
	var amount: Decimal
	var localCurrency: Currency
	var repeats: RepetitionFrequency
	var start: Date?
	var end: Date?

	init(account: Account, displayAmount: Decimal, currency: Currency, amount: Decimal, localCurrency: Currency, repeats: RepetitionFrequency, start: Date? = nil, end: Date? = nil) {
		self.account = account
		self.displayAmount = displayAmount
		self.currency = currency
		self.amount = amount
		self.localCurrency = localCurrency
		self.repeats = repeats
		self.start = start
		self.end = end
	}
}
