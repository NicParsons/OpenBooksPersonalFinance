import SwiftUI
import OBFoundation

struct CurrencyAmount: View {
		let title: String
		@Binding var amount: Decimal
		@Binding var currency: Currency
		let prompt: String
		var canChangeCurrency: Bool = false
		let OB = OBLog()

		var body: some View {
			HStack {
			TextField(title,
				value: $amount,
				format: .currency(code: currency.rawValue),
				//FIXME: THe currency code used in the format does not update when the user selects a different currency from the Picker.
				prompt: Text(prompt))
					.textFieldStyle(.roundedBorder)
					.withDecimalPad()

				if canChangeCurrency {
					CurrencyPicker(selected: $currency)
				.onAppear {
					OB.debug("Currency picker appeared beside amount field.")
				}
				} // if canChangeCurrency
			} // HStack
			.padding()
    } // body
}// View
