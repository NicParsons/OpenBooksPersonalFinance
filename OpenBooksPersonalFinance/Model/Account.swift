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

extension String {
	func adding(_ string: String, withSeparator separator: String = ".", includingLeadingSeparator: Bool = false) -> String {
		var base = self
		if base != "" || includingLeadingSeparator { base.append(separator) }
		base.append(string)
		return base
	}

	func adding(_ integer: Int, withSeparator separator: String = ".", includingLeadingSeparator: Bool = false) -> String {
		var base = self
		let string = String(integer)
		if base != "" || includingLeadingSeparator { base.append(separator) }
		base.append(string)
		return base
	}

	init(fromInt integer: Int, minStringLength: Int = 2) {
		self.init(format: "%0\(minStringLength)d", integer)
	}
}

extension Int {
	func stringified(withMinStringLength: Int = 2) -> String {
		return String(format: "%0\(withMinStringLength)d", self)
	}
}
