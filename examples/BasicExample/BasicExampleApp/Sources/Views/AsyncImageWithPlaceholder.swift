import SwiftUI

struct AsyncImageWithPlaceholder: View {
    @Environment(\.colorScheme) var colorScheme
    let logoURL: URL?
    let size: CGSize

    var body: some View {
        AsyncImage(url: logoURL) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if phase.error != nil {
                Image(systemName: "photo.badge.exclamationmark").font(.system(size: .extraLarge))
                    .background(
                        Circle().fill(.gray.opacity(0.3))
                            .frame(width: size.width, height: size.height)
                    )
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, colorScheme == .dark ? .white : .black)
            } else {
                ProgressView()
            }
        }
        .frame(width: size.width, height: size.height).clipShape(Circle())
    }
}
