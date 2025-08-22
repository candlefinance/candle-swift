import SwiftUI

struct ItemPhoto: View {

    struct Photo: Identifiable {
        let id: UUID = .init()
        let resource: ImageResource
    }

    let photo: Photo

    var body: some View {
        Image(photo.resource).resizable().scaledToFill().aspectRatio(219 / 475, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 36)).shadow(radius: 5)
    }
}
