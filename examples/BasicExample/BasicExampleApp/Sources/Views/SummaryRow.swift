import SwiftUI

struct SummaryRow: View {
    let badges: [Badge]
    let logo: Logo

    var body: some View {
        HStack(spacing: .large) {
            AnyImage(logo: logo, size: .extraLarge)

            HStack(spacing: 8) {
                ForEach(badges) { badge in
                    Text(badge.text).font(.caption.weight(.semibold)).padding(.vertical, 1)
                        .padding(.horizontal, 6).foregroundStyle(.white)
                        .background(badge.color, in: Capsule())
                }
            }

            Spacer()
        }
    }
}
