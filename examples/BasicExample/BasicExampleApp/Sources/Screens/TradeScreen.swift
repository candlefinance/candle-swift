import Candle
import SwiftUI

struct TradeScreen: View {
    enum Side {
        case lost, gained
    }

    @Environment(CandleClient.self) private var client

    @Binding var error: (title: String, message: String)?

    @State private(set) var trade: Models.Trade
    @State private var selectedSide: Side = .lost

    private var badgeText: String {
        trade.state.description
    }

    private var badgeColor: Color {
        switch trade.state {
        case .success: return .green
        case .inProgress: return .yellow
        case .failure: return .red
        }
    }

    @ViewBuilder
    private func logoURLView(asset: Models.TradeAsset) -> some View {
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
                logoURLView(asset: trade.lost)
                    .clipShape(Circle())
                    .shadow(radius: 4)

                VStack(alignment: .center, spacing: 6) {
                    Image(systemName: "chevron.right").frame(minWidth: 16)
                    Text(badgeText)
                        .font(.footnote.weight(.semibold))
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .foregroundStyle(.white)
                        .background(badgeColor, in: Capsule())
                }.frame(maxWidth: .infinity)

                logoURLView(asset: trade.gained)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }

            // FIXME: Show counterparty details
            let date = ISO8601DateFormatter.candle.date(from: trade.dateTime)
            Section(header: Text("Details")) {
                InfoRow(
                    systemImage: "link",
                    title: "Date/Time",
                    value: date?.formatted(date: .complete, time: .complete) ?? trade.dateTime,
                )
            }

            Section(header: Text("Lost Asset")) {
                TradeAssetGroup(tradeAsset: trade.lost)
            }

            Section(header: Text("Gained Asset")) {
                TradeAssetGroup(tradeAsset: trade.gained)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await getTrade()
        }
    }

    private func getTrade() async {
        do {
            trade = try await client.getTrade(ref: trade.ref)
        } catch {
            switch error {
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
                    title: "Unexpected Status Code",
                    message: "Received \(statusCode) response"
                )
            case .sessionError(let sessionError):
                self.error = sessionError.formatted
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            }
        }
    }
}
