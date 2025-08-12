import SwiftUI

struct FormRow: View {
    @Binding var value: String

    let title: String
    let placeholder: String

    var body: some View {
        HStack {
            Text(title).fontWeight(.bold)
            Spacer()
            TextField(placeholder, text: $value).multilineTextAlignment(
                .trailing)
        }
    }
}
