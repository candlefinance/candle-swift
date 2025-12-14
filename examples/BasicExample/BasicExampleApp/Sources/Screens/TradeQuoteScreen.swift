import Candle
import SwiftUI

struct TradeQuoteScreen: View {
    enum Side { case lost, gained }

    @Binding var error: (title: String, message: String)?
    @Binding var tradeQuoteToExecute: Candle.Models.TradeQuote?

    @State private(set) var tradeQuote: Candle.Models.TradeQuote
    @State private var selectedSide: Side = .lost

    private var badgeText: String { "Quote" }

    private var badgeColor: Color { return .blue }

    var body: some View {
        List {
            InfoHeader(
                logo: .url(tradeQuote.logoURL),
                title: tradeQuote.title,
                badges: tradeQuote.badges,
            )

            let expirationDate = ISO8601DateFormatter.candle.date(
                from: tradeQuote.expirationDateTime
            )
            Section(header: Text("Details")) {
                InfoRow(
                    symbol: .clock,
                    title: "Expiration Date/Time",
                    value: expirationDate?.formatted(date: .complete, time: .complete)
                        ?? tradeQuote.expirationDateTime,
                )
            }

            Section(header: Text("Lost Asset")) { TradeAssetGroup(tradeAsset: tradeQuote.lost) }
            Section(header: Text("Gained Asset")) { TradeAssetGroup(tradeAsset: tradeQuote.gained) }
            Section(header: Text("Counterparty")) {
                CounterpartyGroup(counterparty: tradeQuote.counterparty)
            }
        }
        .listStyle(.insetGrouped)
        .toolbar { Button("Request") { tradeQuoteToExecute = tradeQuote }.bold() }
    }
}
