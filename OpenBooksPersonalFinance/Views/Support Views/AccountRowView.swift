import SwiftUI

struct AccountRowView: View {
	@Bindable var account: Account

    var body: some View {
		HStack {
			Text(account.id)
			TextField("Account name", text: $account.name)
			Toggle("Hidden", isOn: $account.hidden)
		}
		.padding()
    }
}
