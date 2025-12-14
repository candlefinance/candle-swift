import SwiftUI

struct QuoteRequestGroupHeader: View {
    let title: String
    let badge: Badge
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(badge.text).font(.footnote.weight(.semibold)).padding(.vertical, 2)
                .padding(.horizontal, 8).foregroundStyle(.white)
                .background(badge.color, in: Capsule())
        }
    }
}
