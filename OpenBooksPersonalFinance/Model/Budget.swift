import Foundation
import SwiftData
import OBFoundation

@Model
final class Budget {
	var startDate: Date
	var endDate: Date
	var lineItems: [BudgetLineItem] = []

	var description: String {
		return "from \(startDate.formatted()) to \(endDate.formatted())"
	}

	init() {
		startDate = Calendar.current.firstOfJuly() ?? Date.now
		endDate = Calendar.current.thirtyJune() ?? Date.now
	 }
} // class
