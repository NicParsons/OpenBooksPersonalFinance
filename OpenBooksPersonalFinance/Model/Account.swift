import Foundation
import SwiftData

@Model
class Account: Identifiable {
	@Attribute(.unique) let id: String
	var name: String
	// parentAccountID should ideally be foreign key to accounts.ID
	var parentAccountID: String?
	var hidden = false
	var deletable = true

	init(id: String, name: String, parentAccountID: String?) {
		self.id = id
		self.name = name
		self.parentAccountID = parentAccountID
	}
}

extension String {
	mutating func appending(_ string: String, withSeparator separator: String = ".", includingLeadingSeparator: Bool = false) {
		if self != "" || includingLeadingSeparator { self.append(separator) }
		self.append(string)
	}

	mutating func appending(_ integer: Int, withSeparator separator: String = ".", includingLeadingSeparator: Bool = false) {
		let string = String(integer)
		if self != "" || includingLeadingSeparator { self.append(separator) }
		self.append(string)
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
