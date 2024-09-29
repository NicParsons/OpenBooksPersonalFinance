import Foundation
import SwiftData
import OBFoundation

@Model
class OpeningBalance {
	@Relationship(inverse: \Account.openingBalance)
	var account: Account
	var amount: Decimal
	var currency: Currency
	var date: Date

	init(account: Account, amount: Decimal = 0, currency: Currency, date: Date) {
		self.account = account
		self.amount = amount
		self.currency = currency
		self.date = date
	}
}
