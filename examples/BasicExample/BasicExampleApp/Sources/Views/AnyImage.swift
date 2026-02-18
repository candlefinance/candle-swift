import SwiftUI

struct AnyImage: View {

    @Environment(\.colorScheme) var colorScheme

    let logo: Logo
    let size: CGFloat

    var body: some View {
        switch logo {
        case .text(let text, let color):
            ZStack {
                Circle().fill(color)
                Text(text).font(.system(size: size, weight: .bold)).minimumScaleFactor(0.1)
                    .foregroundStyle(.white).padding(size * 0.2)
            }
            .frame(width: size, height: size).clipShape(Circle()).shadow(radius: 4)

        case .symbol(let symbol, let color):
            ZStack {
                Circle().fill(color)
                Image(systemSymbol: symbol).resizable().scaledToFit().padding(size * 0.22)
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size).clipShape(Circle()).shadow(radius: 4)

        case .url(let url):
            AsyncImage(url: url, transaction: .init(animation: .default)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill().frame(width: size, height: size)
                case .failure: AnyImage(logo: .symbol(.photo, .red), size: size)
                case .empty: ProgressView().frame(width: size, height: size)
                }
            }
            .clipShape(Circle()).shadow(radius: 4)
        }

    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 12) {
            AnyImage(logo: .text("$", .green), size: 80)
            AnyImage(logo: .text("$", .green), size: 40)
            AnyImage(logo: .text("$", .green), size: 20)
            AnyImage(logo: .text("$", .green), size: 10)
        }
        HStack(spacing: 12) {
            AnyImage(logo: .text("US$", .green), size: 80)
            AnyImage(logo: .text("US$", .green), size: 40)
            AnyImage(logo: .text("US$", .green), size: 20)
            AnyImage(logo: .text("US$", .green), size: 10)
        }

        HStack(spacing: 12) {
            AnyImage(logo: .symbol(.dollarsign, .green), size: 80)
            AnyImage(logo: .symbol(.dollarsign, .green), size: 40)
            AnyImage(logo: .symbol(.dollarsign, .green), size: 20)
            AnyImage(logo: .symbol(.dollarsign, .green), size: 10)
        }

        let invalidURL = "https://candle.png"
        HStack(spacing: 12) {
            AnyImage(logo: .url(URL(string: invalidURL)!), size: 80)
            AnyImage(logo: .url(URL(string: invalidURL)!), size: 40)
            AnyImage(logo: .url(URL(string: invalidURL)!), size: 20)
            AnyImage(logo: .url(URL(string: invalidURL)!), size: 10)
        }

        let candleLogoURL = "https://institution-logos.s3.us-east-1.amazonaws.com/candle.png"
        HStack(spacing: 12) {
            AnyImage(logo: .url(URL(string: candleLogoURL)!), size: 80)
            AnyImage(logo: .url(URL(string: candleLogoURL)!), size: 40)
            AnyImage(logo: .url(URL(string: candleLogoURL)!), size: 20)
            AnyImage(logo: .url(URL(string: candleLogoURL)!), size: 10)
        }
    }
    .padding()
}
