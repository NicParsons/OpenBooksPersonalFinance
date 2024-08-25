import Foundation
import OBFoundation
import SwiftUI

final class AppPreferences {
	@AppStorage("defaultCurrency") var defaultCurrency: Currency = .AUD

} // class
