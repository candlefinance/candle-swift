import SFSafeSymbols
import SwiftUI

struct FormNumberRow<FormatStyle: ParseableFormatStyle>: View
where FormatStyle.FormatOutput == String {
    @Binding var value: FormatStyle.FormatInput?

    let symbol: SFSymbol
    let title: String
    let placeholder: String
    let format: FormatStyle

    var body: some View {
        HStack {
            Image(systemSymbol: symbol).frame(width: 24).foregroundColor(.accentColor)
            Text(title).fontWeight(.bold)

            Spacer()
            TextField(placeholder, value: $value, format: format).keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}
