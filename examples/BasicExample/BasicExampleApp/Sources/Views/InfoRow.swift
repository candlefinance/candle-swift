import SwiftUI

struct InfoRow: View {
    let systemImage: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemImage).frame(width: 24).foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)

                Text(value).font(.body.weight(.medium)).textSelection(.enabled)
            }

            Spacer()

            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless).foregroundStyle(.secondary)
        }
    }
}
