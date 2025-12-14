import Candle
import SwiftUI

struct TradeScreen: View {
    enum Side { case lost, gained }

    @Binding var error: (title: String, message: String)?

    @State private(set) var trade: Candle.Models.Trade
    @State private var selectedSide: Side = .lost

    var body: some View {
        List {
            InfoHeader(logo: .url(trade.logoURL), title: trade.title, badges: trade.badges, )

            // FIXME: Show counterparty details
            let date = ISO8601DateFormatter.candle.date(from: trade.dateTime)
            Section(header: Text("Details")) {
                InfoRow(
                    symbol: .calendar,
                    title: "Date/Time",
                    value: date?.formatted(date: .complete, time: .complete) ?? trade.dateTime,
                )
                InfoRow(symbol: .ellipsis, title: "State", value: trade.state.description, )
            }

            Section(header: Text("Lost Asset")) { TradeAssetGroup(tradeAsset: trade.lost) }
            Section(header: Text("Gained Asset")) { TradeAssetGroup(tradeAsset: trade.gained) }
            Section(header: Text("Counterparty")) {
                CounterpartyGroup(counterparty: trade.counterparty)
            }
        }
        .listStyle(.insetGrouped).refreshable { await getTrade() }
    }

    private func getTrade() async {
        do { trade = try await Candle.Client.shared.getTrade(ref: trade.ref) } catch {
            switch error {
            case .noActiveUser:
                self.error = (title: "No Active User", message: "Go through onboarding again.")
            case .sessionError:
                self.error = (title: "Session Error", message: "Check your internet connection.")
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    self.error = (title: "User Not Found", message: payload.message)
                case .notFound_linkedAccount:
                    self.error = (title: "Linked Account Not Found", message: payload.message)
                case .notFound_trade:
                    self.error = (title: "Trade Not Found", message: payload.message)
                }
            case .unprocessableContent(let payload):
                switch payload.kind {
                case .schemaInvalid_request:
                    self.error = (title: "Request Schema Invalid", message: payload.message)
                }
            case .unauthorized(let payload):
                switch payload.kind {
                case .badAuthorization_user:
                    self.error = (title: "Bad User Authorization", message: payload.message)
                case .badAuthorization_linkedAccount:
                    self.error = (
                        title: "Bad Linked Account Authorization", message: payload.message
                    )
                }
            case .internalServerError(let payload):
                switch payload.kind {
                case .unexpected:
                    self.error = (title: "Internal Server Error", message: payload.message)
                }
            case .unexpectedStatusCode(let statusCode):
                self.error = (
                    title: "Unexpected Status Code", message: "Received \(statusCode) response"
                )
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            case .gatewayTimeout(let payload):
                switch payload.kind {
                case .unavailable_proxy:
                    self.error = (title: "Proxy Unavailable", message: payload.message)
                }
            }
        }
    }
}
