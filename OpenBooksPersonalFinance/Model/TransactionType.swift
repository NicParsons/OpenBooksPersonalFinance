import Foundation

enum TransactionType: String, CaseIterable, Codable, RawRepresentable {
	case credit, debit
}
