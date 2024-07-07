import Foundation

struct Account {
	let id: String // or Int
	var name: String
	var parentAccountID: String // or Int
	var hidden: Bool = false
}
