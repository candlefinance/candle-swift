import Candle
import SwiftUI

struct TradeQuoteScreen: View {
    enum Side { case lost, gained }

    @Environment(CandleClient.self) private var client

    @Binding var error: (title: String, message: String)?
    @Binding var tradeQuoteToExecute: Models.TradeQuote?

    @State private(set) var tradeQuote: Models.TradeQuote
    @State private var selectedSide: Side = .lost

    private var badgeText: String { "Quote" }

    private var badgeColor: Color { return .blue }

    @ViewBuilder private func logoURLView(asset: Models.TradeAsset) -> some View {
        switch asset {
        case .FiatAsset(let fiatAsset):
            AsyncImageWithPlaceholder(
                logoURL: fiatAsset.service.logoURL,
                size: .init(width: 64, height: 64)
            )
        case .MarketTradeAsset(let marketTradeAsset):
            AsyncImageWithPlaceholder(
                logoURL: URL(string: marketTradeAsset.logoURL),
                size: .init(width: 64, height: 64)
            )
        case .TransportAsset(let transportAsset):
            AsyncImageWithPlaceholder(
                logoURL: URL(string: transportAsset.imageURL),
                size: .init(width: 64, height: 64)
            )
        case .OtherAsset: Image(systemName: "storefront.fill").frame(minWidth: 64)
        case .NothingAsset: Image(systemName: "gift.fill").frame(minWidth: 64)
        }
    }

    var body: some View {
        List {
            HStack(alignment: .center, spacing: 16) {
                logoURLView(asset: tradeQuote.lost).clipShape(Circle()).shadow(radius: 4)

                VStack(alignment: .center, spacing: 6) {
                    Image(systemName: "chevron.right").frame(minWidth: 16)
                    Text(badgeText).font(.footnote.weight(.semibold)).padding(.vertical, 2)
                        .padding(.horizontal, 8).foregroundStyle(.white)
                        .background(badgeColor, in: Capsule())
                }
                .frame(maxWidth: .infinity)

                logoURLView(asset: tradeQuote.gained).clipShape(Circle()).shadow(radius: 4)
            }

            let expirationDate = ISO8601DateFormatter.candle.date(
                from: tradeQuote.expirationDateTime
            )
            Section(header: Text("Details")) {
                InfoRow(
                    systemImage: "clock",
                    title: "Expiration Date/Time",
                    value: expirationDate?.formatted(date: .complete, time: .complete)
                        ?? tradeQuote.expirationDateTime,
                )
            }

            Section(header: Text("Lost Asset")) { TradeAssetGroup(tradeAsset: tradeQuote.lost) }

            Section(header: Text("Gained Asset")) { TradeAssetGroup(tradeAsset: tradeQuote.gained) }
        }
        .listStyle(.insetGrouped)
        .toolbar { Button("Request") { tradeQuoteToExecute = tradeQuote }.bold() }
    }
}
