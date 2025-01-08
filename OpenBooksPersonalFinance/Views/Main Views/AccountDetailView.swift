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

				if !account.isParent {
					if let _ = account.openingBalance {
						let openingBalanceBinding = Binding(
							get: { account.openingBalance! },
							set: { account.openingBalance = $0 }
						) // end binding declaration

						CurrencyAmount(title: "Opening balance",
									   amount: openingBalanceBinding.amount,
									   currency: openingBalanceBinding.currency,
									   prompt: "The account's opening balance",
									   canChangeCurrency: true)

						DatePicker("Date opened", selection: openingBalanceBinding.date, displayedComponents: .date)
					} // end if has opening balance
				} // end if is not parent

					Toggle("Hidden", isOn: $account.hidden)

				Toggle("Deletable", isOn: $account.isDeletable)
					.disabled(true)
			} // form
			.padding()
		} // VStack
    } // body
} // view
