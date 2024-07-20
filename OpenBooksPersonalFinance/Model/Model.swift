import Foundation
import SwiftData
import OBFoundation

final class Model {
	var defaultCurrency: Currency = .AUD
	var accounts: [Account] = []
	var transactions: [Transaction] = []

	init() {

	}
}
