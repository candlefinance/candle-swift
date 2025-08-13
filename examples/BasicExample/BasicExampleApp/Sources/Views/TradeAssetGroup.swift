import Candle
import SwiftUI

struct TradeAssetGroup: View {

    let tradeAsset: Models.TradeAsset

    var body: some View {
        DisclosureGroup {
            switch tradeAsset {
            case .FiatAsset(let fiatAsset):
                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        systemImage: "link",
                        title: "Linked Account ID",
                        value: fiatAsset.linkedAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Account ID",
                        value: fiatAsset.serviceAccountID
                    )
                    if let serviceTradeID = fiatAsset.serviceTradeID {
                        InfoRow(
                            systemImage: "number",
                            title: "Service Trade ID",
                            value: serviceTradeID
                        )
                    }
                }

                Section(header: Text("Details").bold()) {
                    InfoRow(
                        systemImage: "banknote",
                        title: "Amount",
                        value: fiatAsset.amount.formatted(
                            .currency(code: fiatAsset.currencyCode)),
                    )
                }

            case .MarketTradeAsset(let marketAsset):
                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        systemImage: "link",
                        title: "Linked Account ID",
                        value: marketAsset.linkedAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Account ID",
                        value: marketAsset.serviceAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Asset ID",
                        value: marketAsset.serviceAssetID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Trade ID",
                        value: marketAsset.serviceTradeID
                    )
                }

                // FIXME: Show color + logoURL
                Section(header: Text("Asset").bold()) {
                    InfoRow(
                        systemImage: "info.circle",
                        title: "Name",
                        value: marketAsset.name,
                    )
                    InfoRow(
                        systemImage: "chart.line.uptrend.xyaxis",
                        title: "Symbol",
                        value: marketAsset.symbol,
                    )
                    InfoRow(
                        systemImage: "banknote",
                        title: "Amount",
                        value: marketAsset.amount.formatted(),
                    )
                }

            case .TransportAsset(let transportAsset):
                Section(header: Text("Metadata").bold()) {
                    InfoRow(
                        systemImage: "link",
                        title: "Linked Account ID",
                        value: transportAsset.linkedAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Account ID",
                        value: transportAsset.serviceAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Asset ID",
                        value: transportAsset.serviceAssetID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Trade ID",
                        value: transportAsset.serviceTradeID
                    )
                }

                // FIXME: Show logoURL and origin/destination coordinates
                Section(header: Text("Details").bold()) {
                    let arrivalDate = ISO8601DateFormatter.candle.date(
                        from: transportAsset.arrivalDateTime)
                    let departureDate = ISO8601DateFormatter.candle.date(
                        from: transportAsset.departureDateTime)

                    InfoRow(
                        systemImage: "info.circle",
                        title: "Description",
                        value: transportAsset.description
                    )
                    InfoRow(
                        systemImage: "sunrise",
                        title: "Departure Date/Time",
                        value: departureDate?.formatted(date: .complete, time: .complete)
                            ?? transportAsset.departureDateTime
                    )
                    InfoRow(
                        systemImage: "sunset",
                        title: "Arrival Date/Time",
                        value: arrivalDate?.formatted(date: .complete, time: .complete)
                            ?? transportAsset.arrivalDateTime
                    )
                    InfoRow(
                        systemImage: "sunrise",
                        title: "Origin Address",
                        value: transportAsset.originAddress.value
                    )
                    InfoRow(
                        systemImage: "sunset",
                        title: "Destination Address",
                        value: transportAsset.destinationAddress.value
                    )
                    InfoRow(
                        systemImage: "figure.seated.seatbelt",
                        title: "Seats",
                        value: String(transportAsset.seats)
                    )
                }

            case .NothingAsset: Spacer()
            case .OtherAsset: Spacer()
            }
        } label: {
            switch tradeAsset {
            case .FiatAsset(let fiatAsset):
                InfoHeader(
                    logoURL: fiatAsset.service.logoURL, title: fiatAsset.currencyCode,
                    badgeText: fiatAsset.assetKind.description, badgeColor: .green)
            case .MarketTradeAsset(let marketAsset):
                let badgeColor = marketAsset.assetKind == .crypto ? Color.orange : .indigo
                InfoHeader(
                    logoURL: marketAsset.service.logoURL, title: marketAsset.name,
                    badgeText: marketAsset.assetKind.description, badgeColor: badgeColor)
            case .TransportAsset(let transportAsset):
                InfoHeader(
                    logoURL: transportAsset.service.logoURL, title: transportAsset.name,
                    badgeText: transportAsset.assetKind.description, badgeColor: .black)
            case .OtherAsset(let otherAsset):
                InfoHeader(
                    logoURL: URL(string: "")!, title: nil,  // TODO
                    badgeText: otherAsset.assetKind.description, badgeColor: .gray)
            case .NothingAsset(let nothingAsset):
                InfoHeader(
                    logoURL: URL(string: "")!, title: nil,  // TODO
                    badgeText: nothingAsset.assetKind.description, badgeColor: .red)

            }
        }
    }
}
