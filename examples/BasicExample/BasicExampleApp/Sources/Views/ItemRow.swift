import SwiftUI

struct ItemRow: View {
    let title: String
    let badges: [Badge]
    let value: String?
    let logo: Logo

    var body: some View {
        HStack(spacing: .large) {
            AnyImage(logo: logo, size: .extraHuge)

            VStack(alignment: .leading, spacing: .small) {
                Text(title).lineLimit(1).font(.headline)

                HStack(spacing: 8) {
                    ForEach(badges) { badge in
                        Text(badge.text).font(.caption.weight(.semibold)).padding(.vertical, 1)
                            .padding(.horizontal, 6).foregroundStyle(.white)
                            .background(badge.color, in: Capsule())
                    }
                }
            }

            Spacer()
            if let value { Text(value) }
        }
    }
}
