import Foundation
import OBFoundation
import SwiftUI

final class AppPreferences {
	@AppStorage("firstLaunch") var firstLaunch = true
	@AppStorage("modelVersion") var modelVersion: Int = 0
	@AppStorage("defaultCurrency") var defaultCurrency: Currency = .AUD

	func resetFirstLaunch() {
		let myLogger = OBLog()
		myLogger.log("About to set firstLaunch to true.")
		firstLaunch = true
		myLogger.log("Set firstLaunch to true.")
	}
} // class
