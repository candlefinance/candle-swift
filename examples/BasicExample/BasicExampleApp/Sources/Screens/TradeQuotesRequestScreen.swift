import Candle
import SwiftUI

struct TradeQuotesRequestScreen: View {
    private enum TradeQuoteAssetKind: String, Codable, Hashable, Sendable, CaseIterable {
        case fiat, stock, crypto, transport
    }

    @Environment(CandleClient.self) private var client
    @Environment(\.dismiss) private var dismiss

    @Binding var error: (title: String, message: String)?
    @Binding var tradeQuoteToExecute: Models.TradeQuote?

    @State private var gainedAssetKind: TradeQuoteAssetKind? = .transport
    @State private var gainedFiatAsset: FiatAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .fiat)
    )
    @State private var gainedStockAsset: MarketAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .stock)
    )
    @State private var gainedCryptoAsset: MarketAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .crypto)
    )
    @State private var gainedTransportAsset: TransportAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .transport)
    )

    @State private var lostAssetKind: TradeQuoteAssetKind? = .fiat
    @State private var lostFiatAsset: FiatAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .fiat)
    )
    @State private var lostStockAsset: MarketAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .stock)
    )
    @State private var lostCryptoAsset: MarketAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .crypto)
    )
    @State private var lostTransportAsset: TransportAssetFormViewModel = .init(
        quoteRequest: .init(assetKind: .transport)
    )

    @State private var selectedLinkedAccountIDs: [Models.LinkedAccountID] = []
    @State private var locationViewModel = LocationViewModel()
    @State private var areRequested: Bool = false
    // FIXME: Add this back
    //    @State private var counterpartyKind: Models.GetTrades.Input.Query.CounterpartyKindPayload? = nil

    let linkedAccounts: [Models.LinkedAccount]

    var gainedAssetQuoteRequest: Models.TradeAssetQuoteRequest {
        switch gainedAssetKind {
        case .transport: return .TransportAssetQuoteRequest(gainedTransportAsset.quoteRequest)
        case .fiat: return .FiatAssetQuoteRequest(gainedFiatAsset.quoteRequest)
        case .stock: return .MarketAssetQuoteRequest(gainedStockAsset.quoteRequest)
        case .crypto: return .MarketAssetQuoteRequest(gainedCryptoAsset.quoteRequest)
        case .none: return .NothingAssetQuoteRequest(.init(assetKind: .nothing))
        }
    }

    var lostAssetQuoteRequest: Models.TradeAssetQuoteRequest {
        switch lostAssetKind {
        case .transport: return .TransportAssetQuoteRequest(lostTransportAsset.quoteRequest)
        case .fiat: return .FiatAssetQuoteRequest(lostFiatAsset.quoteRequest)
        case .stock: return .MarketAssetQuoteRequest(lostStockAsset.quoteRequest)
        case .crypto: return .MarketAssetQuoteRequest(lostCryptoAsset.quoteRequest)
        case .none: return .NothingAssetQuoteRequest(.init(assetKind: .nothing))
        }
    }

    var tradeQuotesRequest: Models.TradeQuotesRequest {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            gained: gainedAssetQuoteRequest,
            lost: lostAssetQuoteRequest,
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Lost Asset")) {
                    Picker("Lost", selection: $lostAssetKind) {
                        Text("Fiat").tag(TradeQuoteAssetKind.fiat)
                        Text("Stock").tag(TradeQuoteAssetKind.stock)
                        Text("Crypto").tag(TradeQuoteAssetKind.crypto)
                        Text("Transport").tag(TradeQuoteAssetKind.transport)
                        Text("Nothing").tag(Optional<TradeQuoteAssetKind>.none)
                    }
                    .pickerStyle(.segmented)
                    switch lostAssetKind {
                    case .fiat: FiatAssetForm(viewModel: $lostFiatAsset)
                    case .crypto: MarketAssetForm(viewModel: $lostCryptoAsset)
                    case .stock: MarketAssetForm(viewModel: $lostStockAsset)
                    case .transport: TransportAssetForm(viewModel: $lostTransportAsset)
                    case nil: NothingAssetForm()
                    }
                }
                Section(header: Text("Gained Asset")) {
                    Picker("Gained", selection: $gainedAssetKind) {
                        Text("Fiat").tag(TradeQuoteAssetKind.fiat)
                        Text("Stock").tag(TradeQuoteAssetKind.stock)
                        Text("Crypto").tag(TradeQuoteAssetKind.crypto)
                        Text("Transport").tag(TradeQuoteAssetKind.transport)
                        Text("Nothing").tag(Optional<TradeQuoteAssetKind>.none)
                    }
                    .pickerStyle(.segmented)
                    switch gainedAssetKind {
                    case .fiat: FiatAssetForm(viewModel: $gainedFiatAsset)
                    case .crypto: MarketAssetForm(viewModel: $gainedCryptoAsset)
                    case .stock: MarketAssetForm(viewModel: $gainedStockAsset)
                    case .transport: TransportAssetForm(viewModel: $gainedTransportAsset)
                    case nil: NothingAssetForm()
                    }
                }
            }
            .navigationTitle("Trade Quotes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // FIXME: Add this back
                        // EnumMenu(name: "Counterparty Kind", selectedCase: $counterpartyKind)
                        LinkedAccountsMenu(
                            linkedAccounts: linkedAccounts,
                            selectedLinkedAccountIDs: $selectedLinkedAccountIDs
                        )
                    } label: {
                        Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Request") { areRequested = true }.bold()
                }
            }
            .navigationDestination(isPresented: $areRequested) {
                TradeQuotesScreen(
                    error: $error,
                    tradeQuoteToExecute: $tradeQuoteToExecute,
                    tradeQuotesRequest: tradeQuotesRequest
                )
            }
        }
    }
}

#Preview {
    TradeQuotesRequestScreen(
        error: .constant(nil),
        tradeQuoteToExecute: .constant(nil),
        linkedAccounts: []
    )
    .environment(CandleClient(appUser: .init(appKey: "", appSecret: "")))
}
