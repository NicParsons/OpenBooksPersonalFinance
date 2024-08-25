import Foundation
import SwiftData

@Model
class Account: Identifiable, Equatable {
	@Attribute(.unique) let id: String
	var name: String
	// parentAccountID should ideally be foreign key to accounts.ID
	var parentAccountID: Account.ID?
	var hidden = false
	var deletable = true

	static func ==(lhs: Account, rhs: Account) -> Bool {
		return lhs.id == rhs.id
	}

	init(id: String, name: String, parentAccountID: String?) {
		self.id = id
		self.name = name
		self.parentAccountID = parentAccountID
	}
}
