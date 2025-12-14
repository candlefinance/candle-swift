import SwiftUI

struct InfoHeader: View {
    let logo: Logo
    let title: String
    let badges: [Badge]

    var body: some View {
        HStack(alignment: .center, spacing: .large) {
            AnyImage(logo: logo, size: .massive)

            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.title3.bold())

                HStack(spacing: 8) {
                    ForEach(badges) { badge in
                        Text(badge.text).font(.footnote.weight(.semibold)).padding(.vertical, 2)
                            .padding(.horizontal, 8).foregroundStyle(.white)
                            .background(badge.color, in: Capsule())
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}
