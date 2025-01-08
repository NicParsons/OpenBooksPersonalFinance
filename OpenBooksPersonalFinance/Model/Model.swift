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

	func addAccount(named accountName: String = "New Account", in parentAccountID: Account.ID? = nil, currency: Currency? = nil, deletable: Bool = true) -> Account {
		let defaultCurrency = currency ?? preferences.defaultCurrency
		let newID = accountManager.newID(inParentCategory: parentAccountID)
		let newAccount = Account(id: newID, name: accountName, parentAccountID: parentAccountID, isDeletable: deletable)
		newAccount.openingBalance = OpeningBalance(account: newAccount, amount: 0.0, currency: defaultCurrency)
		accountManager.accounts.append(newAccount)
			context.insert(newAccount)
		myLogger.log("Created new account named \(newAccount.name) with ID \(newAccount.id).")
		return newAccount
	} // func

	func addAccount(named accountName: String = "New Account", in parentAccount: Account, currency: Currency?, deletable: Bool = true) -> Account {
		return addAccount(named: accountName, in: parentAccount.id, currency: currency, deletable: deletable)
	}

	func delete(_ account: Account, ignoringDeletability: Bool = false) {
		// don't delete an account that has associated transactions
// or child accounts
		if account.hasChildren || account.hasTransactions {
			myLogger.log("Account \(account.name) with ID \(account.id) cannot be deleted as it has associated transactions or child accounts.")
			return
		}

		if account.isDeletable || ignoringDeletability {
			context.delete(account)
			myLogger.log("Deleted account \(account.name) with ID \(account.id).")
			accountManager.accounts.removeAll(where: { $0 == account })
		} else {
			myLogger.log("Could not delete account \(account.name) with ID \(account.id) as it is not deletable.")
		} // end if
	} // func

	func delete(_ accounts: [Account], ignoringDeletability: Bool = false) {
		for account in accounts {
			self.delete(account, ignoringDeletability: ignoringDeletability)
		}
	}

	func deleteSelectedAccounts(_ identifiers: Set<Account.ID>) {
		myLogger.log("Deleting selected accounts matching given Set of account IDs.")
			for accountID in identifiers {
				if let account = accountManager[accountID] {
					self.delete(account)
				}
			}
	} // func

	func deleteAllAccounts(_ ignoringDeletability: Bool = false) {
		myLogger.log("About to delete all accounts with ignoring deletability set to \(ignoringDeletability ? "true" : "false").")
		self.delete(accountManager.accounts, ignoringDeletability: ignoringDeletability)
		myLogger.log("Deleted all accounts.")
	}

	func createDefaultAccounts(withDefaultCurrency defaultCurrency: Currency? = nil) -> Bool {
// to be run on first launch to create default account structure
		let currency = defaultCurrency ?? preferences.defaultCurrency

		// start by deleting earlier accounts, at least for now
		//TODO: Find way to check whether an existing account already exists
		//TODO: account names should be unique
		deleteAllAccounts(true)

// start with assets
		let assets = addAccount(named: "Assets", currency: currency, deletable: false)
		let liquidAssets = addAccount(named: "Liquid assets", in: assets, currency: currency, deletable: false)
		let cash = addAccount(named: "Cash", in: liquidAssets, currency: currency, deletable: false)
		// create cash accounts for local currency
		let bankAccounts = addAccount(named: "Bank accounts", in: liquidAssets, currency: currency, deletable: false)
		let transactionAccount = addAccount(named: "Transaction account", in: bankAccounts, currency: currency)
		let savingsAccount = addAccount(named: "Savings account", in: bankAccounts, currency: currency)
		let nonLiquidAssets = addAccount(named: "Non-liquid assets", in: assets, currency: currency, deletable: false)
		let realProperty = addAccount(named: "Real property", in: nonLiquidAssets, currency: currency)
		let shares = addAccount(named: "Shares", in: nonLiquidAssets, currency: currency)
		let superAnnuation = addAccount(named: "Superannuation", in: nonLiquidAssets, currency: currency)

		// liabilities
		let liabilities = addAccount(named: "Liabilities", currency: currency, deletable: false)
		let debtsOwing = addAccount(named: "Debts owing", in: liabilities, currency: currency, deletable: false)
		let creditCards = addAccount(named: "Credit cards", in: debtsOwing, currency: currency)
		let _ = addAccount(named: "Amex", in: creditCards, currency: currency)
		let shortTermDebt = addAccount(named: "Short-term debt", in: liabilities, currency: currency, deletable: false)
		let longTermDebt = addAccount(named: "Long-term debt", in: liabilities, currency: currency, deletable: false)

		// income
		let income = addAccount(named: "Income", currency: currency, deletable: false)
		let salary = addAccount(named: "Salary", in: income, currency: currency)
		let interestIncome = addAccount(named: "Interest income", in: income, currency: currency)
		let otherIncome = addAccount(named: "Income (other)", in: income, currency: currency)

		// expenses
		let expenses = addAccount(named: "Expenses", currency: currency, deletable: false)
		let household = addAccount(named: "Household", in: expenses, currency: currency)
		let food = addAccount(named: "Food", in: expenses, currency: currency)
		let _ = addAccount(named: "Groceries", in: food, currency: currency)
		let boughtMeals = addAccount(named: "Bought meals", in: food, currency: currency)
		let _ = addAccount(named: "Deliveries", in: boughtMeals, currency: currency)
		let _ = addAccount(named: "Work lunches", in: boughtMeals, currency: currency)
		let _ = addAccount(named: "Eating out", in: boughtMeals, currency: currency)
		let _ = addAccount(named: "Personal", in: expenses, currency: currency)
		let _ = addAccount(named: "Medical", in: expenses, currency: currency)
		let _ = addAccount(named: "Finance", in: expenses, currency: currency)
		let _ = addAccount(named: "Gifts and celebrations", in: expenses, currency: currency)
		let _ = addAccount(named: "Vacation", in: expenses, currency: currency)

		// capital
		let _ = addAccount(named: "Capital", currency: currency, deletable: false)
		myLogger.log("Created all default accounts.")
		return true
	} // func
} // class
