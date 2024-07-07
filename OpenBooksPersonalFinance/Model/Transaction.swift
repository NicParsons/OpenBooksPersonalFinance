import Foundation


struct Transaction {
	let id: Int
	var date: Date
	var description: String
// amount should perhaps be some kind of currency value type that specifies the local currency amount, the currency and the foreign currency amount
// need to consider whether to do sourceAccount and destinationAccount or do proper journal entries
	var sourceAccount: Account
	var destinationAccount: Account

	var reconciledSource: Bool = false
	var reconciledDestination: Bool = false
	var taxDeduction: Bool = false
	var recurring: Bool = false
	var hidden:Bool = false
}
