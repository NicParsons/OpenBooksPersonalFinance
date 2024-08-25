import Foundation
import SwiftData

class AccountManager {
	var context: ModelContext
	var accounts: [Account]
	let numberOfSubcategoryPlaces: Int = 2

	subscript(accountID: String) -> Account? {
		return accounts.first(where: { $0.id == accountID } ) ?? nil
	}

	func childAccounts(of account: Account) -> [Account] {
		return accounts.filter( { $0.parentAccountID == account.id })
	}

	func childAccounts(of accountID: String?) -> [Account] {
		return accounts.filter( { $0.parentAccountID == accountID })
	}

	func allChildAccounts() -> [Account] {
		let parents = parents()
		return accounts.filter( { !parents.contains($0) } )
	}

	func parents() -> [Account] {
		let parentIDs = accounts.filter({ $0.parentAccountID != nil })
			.map ({ $0.id })
		return accounts.filter({ parentIDs.contains($0.id) })
	}

	func siblingAccounts(of account: Account) -> [Account] {
		accounts.filter( { $0.parentAccountID == account.parentAccountID } )
	}

	func siblingAccounts(of accountID: String) -> [Account] {
		let parentAccountID = parentAccountID(of: accountID)
		return accounts.filter( { $0.parentAccountID == parentAccountID } )
	}

	func largestAccountID(from givenAccounts: [Account]) -> String? {
		// can improve this significantly with max method
		let sortedAccounts = givenAccounts.sorted { $0.id < $1.id }
		if let latestAccount = sortedAccounts.last {
			return latestAccount.id
		} else {
// no accounts were passed to the function
return nil
		}
	}

	func categories(of accountID: String) -> [Substring] {
		return accountID.split(separator: ".")
	}

	func foundingFather(of accountID: String) -> String? {
		if let substring = categories(of: accountID).first {
			return String(substring)
		} else {
			return nil
		}
	}

	func parentAccountID(of accountID: String) -> String? {
		// account ID without full stop/period character doesn't have a parent
		if !accountID.contains(".") { return nil }
			// else, it has a parent
			return accountID.components(separatedBy: ".").dropLast(1).joined(separator: ".")
	} // func

	func increment(_ accountID: String) -> String {
		let lastComponent = lastComponent(of: accountID)
		let newSubcategoryInt = 1 + idAsInt(for: lastComponent)
		let newSubcategory = newSubcategoryInt.stringified(withMinStringLength: numberOfSubcategoryPlaces)
		let parentCategoryID = parentAccountID(of: accountID)
		let prefix = parentCategoryID ?? ""
		return prefix.adding(newSubcategory)
	}

	func lastComponent(of accountID: String) -> String {
		if let substring = categories(of: accountID).last {
			return String(substring)
		} else {
return accountID
		}
	}

	func idAsInt(for accountID: String) -> Int {
		return Int(accountID) ?? 0
	}

	func newID(inParentCategory parentAccountID: String?) -> String {
		let children = childAccounts(of: parentAccountID)
		let largest = largestAccountID(from: children)
// largest could be an account ID string or nil
		if let latestAccountID = largest {
			return increment(latestAccountID)
		} else {
			// largest == nil which means
			// no subcategories in this parent category
			//TODO: Should make method for returning the first subcategory in a parent category.
			let parent = parentAccountID ?? ""
			return parent.adding(1.stringified(withMinStringLength: numberOfSubcategoryPlaces))
		} // end if largest
	}

	init(context: ModelContext, accounts: [Account]) {
		self.context = context
		self.accounts = accounts
	}
}

