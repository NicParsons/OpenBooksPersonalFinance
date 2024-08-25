import SwiftUI

struct TransactionDetailView: View {
	@Binding var transaction: Transaction
	@Binding var visible: Bool

    var body: some View {
		VStack {
			Form {
				DatePicker("Transaction date", selection: $transaction.date, displayedComponents: .date)
				TextField("Description", text: $transaction.note, prompt: Text("Describe the transaction"))

				Divider()

				
				AccountPicker(selected: $transaction.sourceAccount, title: "Source account")
				Text("Where did the money come from e.g. for an expense, the credit card, bank account or cash, or for income, the relevant income account")
				AccountPicker(selected: $transaction.sourceAccount, title: "Destination account")
				Text("Where did the money go to e.g. for an expense, the relevant expense account, or for income, the bank account into which the money was paid")

				Spacer()

				Button("Done") {
					visible = false
				} // Button
			} // Form
			.padding()
		} // VStack
    } // body
} // View
