import SwiftUI

struct ItemRow: View {
    let title: String
    let subtitle: String
    let value: String
    let logoURL: URL?

    var body: some View {
        HStack(spacing: .large) {
            AsyncImageWithPlaceholder(
                logoURL: logoURL,
                size: .init(width: .extraHuge, height: .extraHuge)
            )
            VStack(alignment: .leading) {
                Text(title).lineLimit(1).font(.headline)
                Text(subtitle).font(.subheadline)
            }
            Spacer()
            Text(value)
        }
    }
}
