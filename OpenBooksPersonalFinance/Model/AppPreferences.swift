import Foundation
import OBFoundation
import SwiftUI

final class AppPreferences {
	@AppStorage("firstLaunch") var firstLaunch = true
	@AppStorage("modelVersion") var modelVersion: Int = 0
	@AppStorage("defaultCurrency") var defaultCurrency: Currency = .AUD

} // class
