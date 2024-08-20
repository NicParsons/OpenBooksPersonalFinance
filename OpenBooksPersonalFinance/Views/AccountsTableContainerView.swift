import SwiftUI

struct AccountsTableContainerView: View {
	@State private var parentAccountID: Account.ID? = nil

    var body: some View {
		AccountsTableView(parentAccountID: parentAccountID)
    } // body
} // view
