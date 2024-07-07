import Foundation

struct RepetitionFrequency {
	var frequency: Int
	var period: TimePeriod

	var numberOfDays: Int {
		frequency * period.numberOfDays
	} // computed property
} // struct
