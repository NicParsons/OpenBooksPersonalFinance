import Foundation

enum AccountType: String, Codable, RawRepresentable, Identifiable {
	case asset, liability, income, expense, capital
	var id: String { self.rawValue }
}
