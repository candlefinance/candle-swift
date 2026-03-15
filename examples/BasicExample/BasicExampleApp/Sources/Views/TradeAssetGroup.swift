import Candle
import Foundation
import SwiftUI

struct TradeAssetGroup: View {

    let tradeAsset: Candle.Models.TradeAsset

    var body: some View {
        DisclosureGroup {
            switch tradeAsset {
            case .fiat(let fiatAsset):
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

            case .crypto(let cryptoAsset):
                // FIXME: Show color + logoURL
                Section(header: Text("Details").bold()) {
                    InfoRow(symbol: .infoCircle, title: "Symbol", value: cryptoAsset.symbol, )
                    InfoRow(
                        symbol: .banknote,
                        title: "Amount",
                        value: cryptoAsset.amount.formatted(),
                    )
                }

                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        symbol: .arrowLeftArrowRight,
                        title: "Service Trade ID",
                        value: cryptoAsset.serviceTradeID
                    )
                    InfoRow(
                        symbol: .diamond,
                        title: "Service Asset ID",
                        value: cryptoAsset.serviceAssetID
                    )
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: cryptoAsset.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: cryptoAsset.linkedAccountID
                    )
                }

            case .stock(let stockAsset):
                Section(header: Text("Details").bold()) {
                    InfoRow(symbol: .infoCircle, title: "Symbol", value: stockAsset.symbol, )
                    InfoRow(
                        symbol: .banknote,
                        title: "Amount",
                        value: stockAsset.amount.formatted(),
                    )
                }

                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        symbol: .arrowLeftArrowRight,
                        title: "Service Trade ID",
                        value: stockAsset.serviceTradeID
                    )
                    InfoRow(
                        symbol: .diamond,
                        title: "Service Asset ID",
                        value: stockAsset.serviceAssetID
                    )
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: stockAsset.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: stockAsset.linkedAccountID
                    )
                }

            case .transport(let transportAsset):
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

            case .nothing: Spacer()
            case .other: Spacer()
            }
        } label: {
            switch tradeAsset {
            case .fiat(let fiatAsset):
                InfoHeader(
                    logo: .text(
                        Locale.current.localizedSymbol(forCurrencyCode: fiatAsset.currencyCode),
                        .assetKindFiat
                    ),
                    title: Locale.current.localizedString(forCurrencyCode: fiatAsset.currencyCode)
                        ?? fiatAsset.currencyCode,
                    badges: [tradeAsset.badge],
                )
            case .crypto(let cryptoAsset):
                InfoHeader(
                    logo: .url(URL(string: cryptoAsset.logoURL)),
                    title: cryptoAsset.name,
                    badges: [tradeAsset.badge],
                )
            case .stock(let stockAsset):
                InfoHeader(
                    logo: .url(URL(string: stockAsset.logoURL)),
                    title: stockAsset.name,
                    badges: [tradeAsset.badge],
                )
            case .transport(let transportAsset):
                InfoHeader(
                    logo: .url(URL(string: transportAsset.imageURL)),
                    title: transportAsset.name,
                    badges: [tradeAsset.badge],
                )
            case .other:
                InfoHeader(
                    logo: .symbol(.ellipsis, .gray),
                    title: "—",
                    badges: [tradeAsset.badge],
                )
            case .nothing:
                InfoHeader(
                    logo: .symbol(.gift, .assetKindNothing),
                    title: "—",
                    badges: [tradeAsset.badge],
                )
            }
        }
    }
}
