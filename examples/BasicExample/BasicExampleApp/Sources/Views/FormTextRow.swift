import SFSafeSymbols
import SwiftUI

struct FormTextRow: View {
    @Binding var value: String

    let symbol: SFSymbol
    let title: String
    let placeholder: String

    var body: some View {
        HStack {
            Image(systemSymbol: symbol).frame(width: 24).foregroundColor(.accentColor)
            Text(title).fontWeight(.bold)

            Spacer()
            TextField(placeholder, text: $value).multilineTextAlignment(.trailing)
        }
    }
}
