import SwiftUI
import OBFoundation

struct CurrencyPicker: View {
	@Binding var selected: Currency
	var label = "Currency"
var labelHidden = true

	var body: some View {
		Picker(selection: $selected,
			   label: Text(label)
				.accessibilityHidden(labelHidden)
		) {
			ForEach(Currency.allCases) { code in
				Text(code.rawValue).tag(code)
			} // ForEach
		} // Picker
		.pickerStyle(.automatic)
		.hideLabel(labelHidden)
		// This value for the frame is just a wild guess.
		// only needs to be 3 characters wide + padding
	.frame(width: 75)
    } // body
} // View
