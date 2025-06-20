import Candle
import SwiftUI

struct TradeQuotesScreen: View {
    @Environment(\.dismiss) var dismiss

    private enum TradeQuoteAssetKind: String, Codable, Hashable, Sendable, CaseIterable {
        case fiat, stock, crypto, transport
    }

    @Environment(CandleClient.self) private var client

    @State private var locationViewModel = LocationViewModel()
    @State private var errorMessage: String? = nil
    @State private var tradeQuoteViewModels = [TradeQuoteViewModel]()
    @State private var selectedTradeQuote: Models.TradeQuote?
    @State private var isLoading = false
    @State private var textInput1: String = "40.748237"
    @State private var textInput2: String = "-73.984753"
    @State private var textInput3: String = "40.750298"
    @State private var textInput4: String = "-73.993324"
    @State private var executedTrade: Models.Trade?

    // FIXME: Add these back
    //    @State private var lostAssetQuoteRequest: Models.TradeAssetQuoteRequest = .FiatAssetQuoteRequest(.init(assetKind: .fiat))
    @State private var gainedAssetKind: TradeQuoteAssetKind? = nil
    //    @State private var counterpartyKind: Models.GetTrades.Input.Query.CounterpartyKindPayload? = nil

    @State private var selectedLinkedAccountIDs: [Models.LinkedAccountID] = []

    let linkedAccounts: [Models.LinkedAccount]

    var gainedAssetQuoteRequest: Models.TradeAssetQuoteRequest {
        switch gainedAssetKind {
        case .transport:
            return .TransportAssetQuoteRequest(
                .init(
                    assetKind: .transport,
                    originCoordinates: Double(textInput1).flatMap { latitude in
                        Double(textInput2).map { longitude in
                            Models.Coordinates(latitude: latitude, longitude: longitude)
                        }
                    },
                    destinationCoordinates: Double(textInput3).flatMap { latitude in
                        Double(textInput4).map { longitude in
                            Models.Coordinates(latitude: latitude, longitude: longitude)
                        }
                    }
                ))
        case .fiat:
            return .FiatAssetQuoteRequest(
                .init(assetKind: .fiat, currencyCode: textInput1, amount: Double(textInput2)))
        case .stock:
            return .MarketAssetQuoteRequest(
                .init(assetKind: .stock, symbol: textInput1, amount: Double(textInput2)))
        case .crypto:
            return .MarketAssetQuoteRequest(
                .init(assetKind: .crypto, symbol: textInput1, amount: Double(textInput2)))
        case .none:
            return .NothingAssetQuoteRequest(.init(assetKind: .nothing))
        }
    }

    var tradeQuoteRequest: Models.TradeQuoteRequest {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            gained: gainedAssetQuoteRequest
        )
    }

    var body: some View {
        NavigationStack {
            if isLoading {
                Spacer()
                ProgressView {
                    Text("Loading...")
                }
                Spacer()
            } else {
                // FIXME: Set placeholder dynamically based on selected asset kinds
                TextField("Origin Latitude/Currency Code/Symbol", text: $textInput1)
                TextField("Origin Longitude/Amount", text: $textInput2)
                TextField("Destination Latitude", text: $textInput3)
                TextField("Destination Longitude", text: $textInput4)
                List {
                    ForEach(tradeQuoteViewModels) { tradeQuoteViewModel in
                        NavigationLink(destination: ItemScreen(viewModel: tradeQuoteViewModel)) {
                            ItemRow(viewModel: tradeQuoteViewModel)
                        }.swipeActions {
                            Button("Execute") {
                                selectedTradeQuote = tradeQuoteViewModel.tradeQuote
                            }
                            .tint(.green)
                        }
                    }
                }
                .overlay {
                    if tradeQuoteViewModels.isEmpty {
                        ContentUnavailableView(
                            "No Trade Quotes",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text("Try changing your request or linking more accounts.")
                        )
                    }
                }
                .navigationTitle("Trade Quotes")
                .refreshable {
                    await loadTradeQuotes(request: tradeQuoteRequest, showLoading: false)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            // FIXME: Add these back
                            //                            EnumMenu(name: "Lost Asset Kind", selectedCase: $lostAssetKind)
                            EnumMenu(
                                name: "Gained Asset Kind", selectedCase: $gainedAssetKind)
                            //                            EnumMenu(
                            //                                name: "Counterparty Kind", selectedCase: $counterpartyKind)
                            LinkedAccountsMenu(
                                linkedAccounts: linkedAccounts,
                                selectedLinkedAccountIDs: $selectedLinkedAccountIDs
                            )
                        } label: {
                            Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationDestination(item: $executedTrade) { executedTrade in
            ItemScreen(viewModel: TradeViewModel(client: client, trade: executedTrade))
        }
        .candleTradeExecutionSheet(item: $selectedTradeQuote) { result in
            switch result {
            case .success(let trade):
                executedTrade = trade
            case .failure(let error):
                // FIXME: Why are we returning this error anyway?
                print("error", error)
            }
        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"), message: Text(errorMessage ?? "No Message"),
                dismissButton: .cancel(Text("OK"), action: { errorMessage = nil }))
        }
        /// FIXME: Add this back
        //        .task(id: tradeQuoteRequest) {
        //            await loadTradeQuotes(request: tradeQuoteRequest)
        //        }
        .sensoryFeedback(.error, trigger: errorMessage) { $1 != nil }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(.extraLarge)
        .onAppear { locationViewModel.requestLocation() }
        .onChange(of: locationViewModel.coordinate) { _, coordinate in
            if let coordinate {
                textInput1 = "\(coordinate.latitude)"
                textInput2 = "\(coordinate.longitude)"
            }
        }
    }

    private func loadTradeQuotes(
        request: Models.TradeQuoteRequest, showLoading: Bool = true
    ) async {
        guard !isLoading else { return }
        isLoading = showLoading
        defer { isLoading = false }
        do {
            tradeQuoteViewModels = try await client.getTradeQuotes(request: request).map {
                TradeQuoteViewModel(tradeQuote: $0)
            }
        } catch {
            errorMessage = String(describing: error)
        }
    }
}

#Preview {
    TradesScreen(linkedAccounts: [])
        .environment(
            CandleClient(appUser: .init(appKey: "DEBUG_APP_KEY", appSecret: "DEBUG_APP_SECRET")))
}
