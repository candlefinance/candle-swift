import SFSafeSymbols
import SwiftUI

struct FormChoiceRow: View {
    struct AllowedValue: Identifiable, CustomStringConvertible {
        let id: String
        let description: String
        let logo: Logo
    }
    @Binding var selectedValueID: String?

    let allowedValues: [AllowedValue]
    let symbol: SFSymbol
    let title: String
    let placeholder: String
    var allAllowedValues: [AllowedValue] {
        [.init(id: "", description: placeholder, logo: .symbol(.wandAndRays, .black))]
            + allowedValues
    }

    var body: some View {
        HStack {
            Image(systemSymbol: symbol).frame(width: 24).foregroundColor(.accentColor)
            Text(title).fontWeight(.bold)

            Spacer()
            Menu {
                ForEach(allAllowedValues, id: \.id) { allowedValue in
                    Button(action: { selectedValueID = allowedValue.id }) {
                        Label {
                            Text(allowedValue.description)
                        } icon: {
                            // FIXME: Get rounded corners working (custom menu?)
                            AnyImage(logo: allowedValue.logo, size: .medium)
                        }
                    }
                }
            } label: {
                if let selectedValueID,
                    let selectedValue = allowedValues.first(where: { $0.id == selectedValueID })
                {
                    Text(selectedValue.description).frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Text(placeholder).frame(maxWidth: .infinity, alignment: .trailing)
                }
                Image(systemSymbol: .chevronDown).frame(width: 24).foregroundColor(.accentColor)
            }
        }
    }
}
