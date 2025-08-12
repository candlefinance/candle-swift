import SwiftUI

struct InfoHeader: View {
    let logoURL: URL
    let title: String?
    let badgeText: String
    let badgeColor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            AsyncImageWithPlaceholder(
                logoURL: logoURL,
                size: .init(width: 64, height: 64)
            )
            .clipShape(Circle())
            .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 6) {
                if let title {
                    Text(title)
                        .font(.title3.bold())
                }

                Text(badgeText)
                    .font(.footnote.weight(.semibold))
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .foregroundStyle(.white)
                    .background(badgeColor, in: Capsule())
            }
            Spacer(minLength: 0)
        }
    }
}
