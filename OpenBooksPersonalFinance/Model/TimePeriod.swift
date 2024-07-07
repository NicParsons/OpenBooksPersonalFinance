import Foundation

enum TimePeriod: String, CaseIterable {
	// maybe should just be string type
	// and have function that switches over the cases and returns numberOfDays
	case daily, weekly, fortnightly, monthly, yearly, times

	var numberOfDays: Int {
		switch self {
		case .daily, .times:
			return 1
		case .weekly:
			return 7
		case .fortnightly:
			return 14
		case .monthly:
			return 30
		case .yearly:
			return 365
		} // switch
	} // computed property
} // enum

