import Foundation
import SwiftData

@Model
class RepetitionFrequency {
	var frequency: Int
	var period: TimePeriod

	var numberOfDays: Int {
		frequency * period.numberOfDays
	} // computed property

	init(frequency: Int, period: TimePeriod) {
		self.frequency = frequency
		self.period = period
	}
} // struct
