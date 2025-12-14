import Candle
import Foundation
import SwiftUI

struct TradeAssetGroup: View {

    let tradeAsset: Candle.Models.TradeAsset

    var body: some View {
        DisclosureGroup {
            switch tradeAsset {
            case .FiatAsset(let fiatAsset):
                Section(header: Text("Details").bold()) {
                    InfoRow(
                        symbol: .banknote,
                        title: "Amount",
                        value: fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode)),
                    )
                }
                Section(header: Text("Metadata").bold()) {
                    if let serviceTradeID = fiatAsset.serviceTradeID {
                        InfoRow(
                            symbol: .arrowLeftArrowRight,
                            title: "Service Trade ID",
                            value: serviceTradeID
                        )
                    }
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: fiatAsset.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: fiatAsset.linkedAccountID
                    )
                }

            case .MarketTradeAsset(let marketAsset):
                // FIXME: Show color + logoURL
                Section(header: Text("Details").bold()) {
                    InfoRow(symbol: .infoCircle, title: "Symbol", value: marketAsset.symbol, )
                    InfoRow(
                        symbol: .banknote,
                        title: "Amount",
                        value: marketAsset.amount.formatted(),
                    )
                }

                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        symbol: .arrowLeftArrowRight,
                        title: "Service Trade ID",
                        value: marketAsset.serviceTradeID
                    )
                    InfoRow(
                        symbol: .diamond,
                        title: "Service Asset ID",
                        value: marketAsset.serviceAssetID
                    )
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: marketAsset.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: marketAsset.linkedAccountID
                    )
                }

            case .TransportAsset(let transportAsset):
                // FIXME: Show logoURL and origin/destination coordinates
                Section(header: Text("Details").bold()) {
                    let arrivalDate = ISO8601DateFormatter.candle.date(
                        from: transportAsset.arrivalDateTime
                    )
                    let departureDate = ISO8601DateFormatter.candle.date(
                        from: transportAsset.departureDateTime
                    )

                    InfoRow(
                        symbol: .infoCircle,
                        title: "Description",
                        value: transportAsset.description
                    )
                    InfoRow(
                        symbol: .sunrise,
                        title: "Departure Date/Time",
                        value: departureDate?.formatted(date: .complete, time: .complete)
                            ?? transportAsset.departureDateTime
                    )
                    InfoRow(
                        symbol: .sunset,
                        title: "Arrival Date/Time",
                        value: arrivalDate?.formatted(date: .complete, time: .complete)
                            ?? transportAsset.arrivalDateTime
                    )
                    InfoRow(
                        symbol: .sunrise,
                        title: "Origin Address",
                        value: transportAsset.originAddress.value
                    )
                    InfoRow(
                        symbol: .sunset,
                        title: "Destination Address",
                        value: transportAsset.destinationAddress.value
                    )
                    InfoRow(
                        symbol: .figureSeatedSeatbelt,
                        title: "Seats",
                        value: String(transportAsset.seats)
                    )
                }

                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        symbol: .arrowLeftArrowRight,
                        title: "Service Trade ID",
                        value: transportAsset.serviceTradeID
                    )
                    InfoRow(
                        symbol: .diamond,
                        title: "Service Asset ID",
                        value: transportAsset.serviceAssetID
                    )
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: transportAsset.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: transportAsset.linkedAccountID
                    )
                }

            case .NothingAsset: Spacer()
            case .OtherAsset: Spacer()
            }
        } label: {
            switch tradeAsset {
            case .FiatAsset(let fiatAsset):
                InfoHeader(
                    logo: .text(
                        Locale.current.localizedSymbol(forCurrencyCode: fiatAsset.currencyCode),
                        .assetKindFiat
                    ),
                    title: Locale.current.localizedString(forCurrencyCode: fiatAsset.currencyCode)
                        ?? fiatAsset.currencyCode,
                    badges: [tradeAsset.badge],
                )
            case .MarketTradeAsset(let marketAsset):
                InfoHeader(
                    logo: .url(URL(string: marketAsset.logoURL)),
                    title: marketAsset.name,
                    badges: [tradeAsset.badge],
                )
            case .TransportAsset(let transportAsset):
                InfoHeader(
                    logo: .url(URL(string: transportAsset.imageURL)),
                    title: transportAsset.name,
                    badges: [tradeAsset.badge],
                )
            case .OtherAsset:
                InfoHeader(
                    logo: .symbol(.ellipsis, .gray),
                    title: "—",
                    badges: [tradeAsset.badge],
                )
            case .NothingAsset:
                InfoHeader(
                    logo: .symbol(.gift, .assetKindNothing),
                    title: "—",
                    badges: [tradeAsset.badge],
                )
            }
        }
    }
}
