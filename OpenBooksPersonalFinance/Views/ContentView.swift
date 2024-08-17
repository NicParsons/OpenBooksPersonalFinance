import SwiftUI
import SwiftData

struct ContentView: View {
	@State private var parentAccountID: String? = nil
	var body: some View {
		AccountsTableView(parentAccountID: parentAccountID)
	}
}
