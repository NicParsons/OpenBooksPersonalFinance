import Foundation
import SwiftData

@Model
class Account: Identifiable {
	@Attribute(.unique) let id: String
	var name: String
	// parentAccountID should ideally be foreign key to accounts.ID
	var parentAccountID: String?
	var hidden: Bool = false

	init(id: String, name: String, parentAccountID: String?) {
		self.id = id
		self.name = name
		self.parentAccountID = parentAccountID
	}
}

extension Account {
	func newIDFor(parentID: String, subCategoryID: Int) -> String {
		var newID = parentID
		newID.appending(subCategoryID)
		return newID
	}
}

extension String {
	mutating func appending(_ string: String, withSeparator separator: String = ".") {
		self.append(separator)
		self.append(string)
	}

	mutating func appending(_ integer: Int, withSeparator separator: String = ".") {
		let string = String(integer)
		self.append(separator)
		self.append(string)
	}
}
