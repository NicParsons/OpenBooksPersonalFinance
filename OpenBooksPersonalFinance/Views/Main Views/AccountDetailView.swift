import SwiftUI

struct AccountDetailView: View {
	@Bindable var account: Account
	@Binding var visible: Bool

    var body: some View {
		VStack {
			Form {
				HStack {
					Text("ID")
					Text(account.id)
				} // HStack
				.padding()
				.accessibilityElement(children: .combine)

				TextField("Account name", text: $account.name)

					Toggle("Hidden", isOn: $account.hidden)

				Toggle("Deletable", isOn: $account.isDeletable)
					.disabled(true)
			} // form
			.padding()
		} // VStack
    } // body
} // view
