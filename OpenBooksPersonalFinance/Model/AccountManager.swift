import Foundation
import SwiftData
import OBFoundation

class AccountManager {
	var context: ModelContext
	var accounts: [Account]
	let numberOfSubcategoryPlaces: Int = 2
	let myLogger = OBLog()

	subscript(accountID: String) -> Account? {
		return accounts.first(where: { $0.id == accountID } ) ?? nil
	}

	static var all: FetchDescriptor<Account> {
		FetchDescriptor<Account>()
	}

	func totalCredits(for account: Account, from startDate: Date, to endDate: Date) -> Decimal {
		let relevantTransactions = account.incomingTransactions.filter({
			$0.date >= startDate && $0.date <= endDate
		})
		return relevantTransactions.sum(\.amount)
	}

	func childAccounts(of account: Account) -> [Account] {
		return accounts.filter( { $0.parentAccountID == account.id })
	}

	func childAccounts(of accountID: String?) -> [Account] {
		return accounts.filter( { $0.parentAccountID == accountID })
	}

	func allParentAccountIDs() -> [Account.ID] {
		// because we are first filtering the array to exclude elements where parentAccountID = nil
		// it is safe to unwrap parentAccountID as we know it will not be nil
return accounts.filter({ $0.parentAccountID != nil })
			.map ({ $0.parentAccountID! }) // unwrapped
	}

	func parents() -> [Account] {
		let parentIDs = allParentAccountIDs()
		return accounts.filter({ parentIDs.contains($0.id) })
	}

	func childlessAccounts() -> [Account] {
		let parentIDs = allParentAccountIDs()
		return accounts.filter( { !parentIDs.contains($0.id) } )
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

	func addAccount(named accountName: String = "New Account", in parentAccountID: Account.ID? = nil, deletable: Bool = true) -> Account {
		let newID = newID(inParentCategory: parentAccountID)
		let newAccount = Account(id: newID, name: accountName, parentAccountID: parentAccountID, isDeletable: deletable)
		accounts.append(newAccount)
			context.insert(newAccount)
		myLogger.log("Created new account named \(newAccount.name) with ID \(newAccount.id).")
		return newAccount
	} // func

	func addAccount(named accountName: String = "New Account", in parentAccount: Account, deletable: Bool = true) -> Account {
		return addAccount(named: accountName, in: parentAccount.id, deletable: deletable)
	}

	func deleteSelectedAccounts(_ identifiers: Set<Account.ID>) {
			for accountID in identifiers {
				if let account = self[accountID] {
					self.delete(account)
				}
			}
	} // func

	func delete(_ account: Account, ignoringDeletability: Bool = false) {
		if account.isDeletable || ignoringDeletability {
			context.delete(account)
			myLogger.log("Deleted account \(account.name) with ID \(account.id).")
		} else {
			myLogger.log("Could not delete account \(account.name) with ID \(account.id) as it is not deletable.")
		} // end if
	} // func

	func delete(_ accounts: [Account], ignoringDeletability: Bool = false) {
		for account in accounts {
			self.delete(account, ignoringDeletability: ignoringDeletability)
		}
	}

	func createDefaultAccounts() -> Bool {
// to be run on first launch to create default account structure
		// start by deleting earlier accounts, at least for now
		//TODO: Find way to check whether an existing account already exists
		//TODO: account names should be unique
		delete(accounts, ignoringDeletability: true)

// start with assets
		let assets = addAccount(named: "Assets", deletable: false)
		let liquidAssets = addAccount(named: "Liquid assets", in: assets, deletable: false)
		let cash = addAccount(named: "Cash", in: liquidAssets, deletable: false)
		// create cash accounts for local currency
		let bankAccounts = addAccount(named: "Bank accounts", in: liquidAssets, deletable: false)
		let transactionAccount = addAccount(named: "Transaction account", in: bankAccounts)
		let savingsAccount = addAccount(named: "Savings account", in: bankAccounts)
		let nonLiquidAssets = addAccount(named: "Non-liquid assets", in: assets, deletable: false)
		let realProperty = addAccount(named: "Real property", in: nonLiquidAssets)
		let shares = addAccount(named: "Shares", in: nonLiquidAssets)
		let superAnnuation = addAccount(named: "Superannuation", in: nonLiquidAssets)

		// liabilities
		let liabilities = addAccount(named: "Liabilities", deletable: false)
		let debtsOwing = addAccount(named: "Debts owing", in: liabilities, deletable: false)
		let creditCards = addAccount(named: "Credit cards", in: debtsOwing)
		let _ = addAccount(named: "Amex", in: creditCards)
		let shortTermDebt = addAccount(named: "Short-term debt", in: liabilities, deletable: false)
		let longTermDebt = addAccount(named: "Long-term debt", in: liabilities, deletable: false)

		// income
		let income = addAccount(named: "Income", deletable: false)
		let salary = addAccount(named: "Salary", in: income)
		let interestIncome = addAccount(named: "Interest income", in: income)
		let otherIncome = addAccount(named: "Income (other)", in: income)

		// expenses
		let expenses = addAccount(named: "Expenses", deletable: false)
		let household = addAccount(named: "Household", in: expenses)
		let food = addAccount(named: "Food", in: expenses)
		let _ = addAccount(named: "Groceries", in: food)
		let boughtMeals = addAccount(named: "Bought meals", in: food)
		let _ = addAccount(named: "Deliveries", in: boughtMeals)
		let _ = addAccount(named: "Work lunches", in: boughtMeals)
		let _ = addAccount(named: "Eating out", in: boughtMeals)
		let _ = addAccount(named: "Personal", in: expenses)
		let _ = addAccount(named: "Medical", in: expenses)
		let _ = addAccount(named: "Finance", in: expenses)
		let _ = addAccount(named: "Gifts and celebrations", in: expenses)
		let _ = addAccount(named: "Vacation", in: expenses)

		// capital
		let capital = addAccount(named: "Capital", deletable: false)
		myLogger.log("Created all default accounts.")
		return true
	} // func

	init(context: ModelContext) {
		self.context = context
		do {
			self.accounts = try context.fetch(AccountManager.all)
		} catch {
			OBLog().error("Unable to fetch Account models when initialising AccountManager.")
			self.accounts = []
		} // do try catch
	} // init
} // class

extension Sequence where Element: AdditiveArithmetic {
	func sum() -> Element {
		reduce(.zero, +)
	}
}

extension Sequence {
	func sum<T: AdditiveArithmetic>(_ predicate: (Element) -> T) -> T {
		reduce(.zero) { $0 + predicate($1) }
	}
}
