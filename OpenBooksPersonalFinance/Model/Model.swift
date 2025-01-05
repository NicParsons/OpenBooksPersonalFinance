import Foundation
import OBFoundation
import SwiftData

@Observable
final class Model {
	let preferences = AppPreferences()
	//TODO: This will double up on the domain, so need to modify the init for OBLog.
	let myLogger = OBLog(Bundle.main.bundleIdentifier ?? "app.openbooks.openbooks-personal-finance")
	let context: ModelContext
	let transactionManager: TransactionManager
	let accountManager: AccountManager

	init(context: ModelContext) {
		self.context = context
		transactionManager = TransactionManager(context: context)
		accountManager = AccountManager(context: context)
	} // init
} // class
