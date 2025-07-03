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

    @State private var linkedAccountStatusRefViewModels = [LinkedAccountStatusRefViewModel]()
    @State private var tradeQuoteViewModels = [TradeQuoteViewModel]()

    @State private var selectedTradeQuote: Models.TradeQuote?
    @State private var isLoading = false
    @State private var executedTrade: Models.Trade?

    @State private var gainedTextInput1: String = "40.748237"
    @State private var gainedTextInput2: String = "-73.984753"
    @State private var gainedTextInput3: String = "40.750298"
    @State private var gainedTextInput4: String = "-73.993324"

    @State private var lostTextInput1: String = ""
    @State private var lostTextInput2: String = ""
    @State private var lostTextInput3: String = ""
    @State private var lostTextInput4: String = ""

    @State private var gainedAssetKind: TradeQuoteAssetKind? = nil
    @State private var lostAssetKind: TradeQuoteAssetKind? = nil

    private var gainedTextInput1Placeholder: String {
        guard let gainedAssetKind else {
            return "Please Select Gained Asset Kind"
        }
        switch gainedAssetKind {
        case .fiat:
            return "Currency Code"
        case .stock:
            return "Stock Symbol"
        case .crypto:
            return "Crypto Symbol"
        case .transport:
            return "Origin Latitude"
        }
    }

    private var gainedTextInput2Placeholder: String {
        guard let gainedAssetKind else {
            return "Please Select Gained Asset Kind"
        }
        switch gainedAssetKind {
        case .fiat, .stock, .crypto:
            return "Amount"
        case .transport:
            return "Origin Longitude"
        }
    }

    private var gainedTextInput3Placeholder: String {
        guard let gainedAssetKind else {
            return "Please Select Gained Asset Kind"
        }
        switch gainedAssetKind {
        case .fiat, .stock, .crypto:
            return "Service Account ID"
        case .transport:
            return "Destination Latitude"
        }
    }

    private var gainedTextInput4Placeholder: String? {
        guard let gainedAssetKind else {
            return "Please Select Gained Asset Kind"
        }
        switch gainedAssetKind {
        case .fiat, .stock, .crypto:
            return nil
        case .transport:
            return "Destination Longitude"
        }
    }

    private var lostTextInput1Placeholder: String {
        guard let lostAssetKind else {
            return "Please Select Lost Asset Kind"
        }
        switch lostAssetKind {
        case .fiat:
            return "Currency Code"
        case .stock:
            return "Stock Symbol"
        case .crypto:
            return "Crypto Symbol"
        case .transport:
            return "Origin Latitude"
        }
    }

    private var lostTextInput2Placeholder: String {
        guard let lostAssetKind else {
            return "Please Select Lost Asset Kind"
        }
        switch lostAssetKind {
        case .fiat, .stock, .crypto:
            return "Amount"
        case .transport:
            return "Origin Longitude"
        }
    }

    private var lostTextInput3Placeholder: String {
        guard let lostAssetKind else {
            return "Please Select Lost Asset Kind"
        }
        switch lostAssetKind {
        case .fiat, .stock, .crypto:
            return "Service Account ID"
        case .transport:
            return "Destination Latitude"
        }
    }

    private var lostTextInput4Placeholder: String? {
        guard let lostAssetKind else {
            return "Please Select Lost Asset Kind"
        }
        switch lostAssetKind {
        case .fiat, .stock, .crypto:
            return nil
        case .transport:
            return "Destination Longitude"
        }
    }
    // FIXME: Add this back
    //    @State private var counterpartyKind: Models.GetTrades.Input.Query.CounterpartyKindPayload? = nil

    @State private var selectedLinkedAccountIDs: [Models.LinkedAccountID] = []

    let linkedAccounts: [Models.LinkedAccount]

    var gainedAssetQuoteRequest: Models.TradeAssetQuoteRequest {
        switch gainedAssetKind {
        case .transport:
            return .TransportAssetQuoteRequest(
                .init(
                    assetKind: .transport,
                    originCoordinates: Double(gainedTextInput1).flatMap { latitude in
                        Double(gainedTextInput2).map { longitude in
                            Models.Coordinates(latitude: latitude, longitude: longitude)
                        }
                    },
                    destinationCoordinates: Double(gainedTextInput3).flatMap { latitude in
                        Double(gainedTextInput4).map { longitude in
                            Models.Coordinates(latitude: latitude, longitude: longitude)
                        }
                    }
                ))
        case .fiat:
            let currencyCode = gainedTextInput1.isEmpty ? nil : gainedTextInput1
            let serviceAccountID = gainedTextInput3.isEmpty ? nil : gainedTextInput3
            return .FiatAssetQuoteRequest(
                .init(
                    assetKind: .fiat, serviceAccountID: serviceAccountID,
                    currencyCode: currencyCode, amount: Double(gainedTextInput2)))
        case .stock:
            let symbol = gainedTextInput1.isEmpty ? nil : gainedTextInput1
            return .MarketAssetQuoteRequest(
                .init(assetKind: .stock, symbol: symbol, amount: Double(gainedTextInput2)))
        case .crypto:
            let symbol = gainedTextInput1.isEmpty ? nil : gainedTextInput1
            return .MarketAssetQuoteRequest(
                .init(assetKind: .crypto, symbol: symbol, amount: Double(gainedTextInput2)))
        case .none:
            return .NothingAssetQuoteRequest(.init(assetKind: .nothing))
        }
    }

    var lostAssetQuoteRequest: Models.TradeAssetQuoteRequest {
        switch lostAssetKind {
        case .transport:
            return .TransportAssetQuoteRequest(
                .init(
                    assetKind: .transport,
                    originCoordinates: Double(lostTextInput1).flatMap { latitude in
                        Double(lostTextInput2).map { longitude in
                            Models.Coordinates(latitude: latitude, longitude: longitude)
                        }
                    },
                    destinationCoordinates: Double(lostTextInput3).flatMap { latitude in
                        Double(lostTextInput4).map { longitude in
                            Models.Coordinates(latitude: latitude, longitude: longitude)
                        }
                    }
                ))
        case .fiat:
            let currencyCode = lostTextInput1.isEmpty ? nil : lostTextInput1
            let serviceAccountID = lostTextInput3.isEmpty ? nil : lostTextInput3
            return .FiatAssetQuoteRequest(
                .init(
                    assetKind: .fiat, serviceAccountID: serviceAccountID,
                    currencyCode: currencyCode, amount: Double(lostTextInput2)))
        case .stock:
            let symbol = lostTextInput1.isEmpty ? nil : lostTextInput1
            return .MarketAssetQuoteRequest(
                .init(assetKind: .stock, symbol: symbol, amount: Double(lostTextInput2)))
        case .crypto:
            let symbol = lostTextInput1.isEmpty ? nil : lostTextInput1
            return .MarketAssetQuoteRequest(
                .init(assetKind: .crypto, symbol: symbol, amount: Double(lostTextInput2)))
        case .none:
            return .NothingAssetQuoteRequest(.init(assetKind: .nothing))
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
            if isLoading {
                Spacer()
                ProgressView {
                    Text("Loading...")
                }
                Spacer()
            } else {
                // FIXME: Set placeholder dynamically based on selected asset kinds
                Text("Gained:").frame(maxWidth: .infinity, alignment: .leading)
                TextField(gainedTextInput1Placeholder, text: $gainedTextInput1)
                TextField(gainedTextInput2Placeholder, text: $gainedTextInput2)
                TextField(gainedTextInput3Placeholder, text: $gainedTextInput3)
                gainedTextInput4Placeholder.map {
                    TextField($0, text: $gainedTextInput4)
                }
                Text("Gained:").frame(maxWidth: .infinity, alignment: .leading)
                TextField(lostTextInput1Placeholder, text: $lostTextInput1)
                TextField(lostTextInput2Placeholder, text: $lostTextInput2)
                TextField(lostTextInput3Placeholder, text: $lostTextInput3)
                lostTextInput4Placeholder.map {
                    TextField($0, text: $lostTextInput4)
                }
                List {
                    Section(header: Text("Linked Accounts")) {
                        ForEach(linkedAccountStatusRefViewModels) {
                            linkedAccountStatusRefViewModel in
                            ItemRow(viewModel: linkedAccountStatusRefViewModel)
                        }
                    }
                    Section(header: Text("Trade Quotes")) {
                        ForEach(tradeQuoteViewModels) { tradeQuoteViewModel in
                            NavigationLink(destination: ItemScreen(viewModel: tradeQuoteViewModel))
                            {
                                ItemRow(viewModel: tradeQuoteViewModel)
                            }.swipeActions {
                                Button("Execute") {
                                    selectedTradeQuote = tradeQuoteViewModel.tradeQuote
                                }
                                .tint(.green)
                            }
                        }
                    }.overlay {
                        if tradeQuoteViewModels.isEmpty {
                            ContentUnavailableView(
                                "No Trade Quotes",
                                systemImage: "exclamationmark.magnifyingglass",
                                description: Text(
                                    "Try changing your request or linking more accounts.")
                            )
                        }
                    }
                }
                .navigationTitle("Trade Quotes")
                .refreshable {
                    await loadTradeQuotes(request: tradeQuotesRequest, showLoading: false)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            // FIXME: Add these back
                            EnumMenu(name: "Gained Asset Kind", selectedCase: $gainedAssetKind)
                            EnumMenu(name: "Lost Asset Kind", selectedCase: $lostAssetKind)
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
                gainedTextInput1 = "\(coordinate.latitude)"
                gainedTextInput2 = "\(coordinate.longitude)"
            }
        }
    }

    private func loadTradeQuotes(
        request: Models.TradeQuotesRequest, showLoading: Bool = true
    ) async {
        guard !isLoading else { return }
        isLoading = showLoading
        defer { isLoading = false }
        do {
            let tradeQuotesResponse = try await client.getTradeQuotes(request: request)
            linkedAccountStatusRefViewModels = tradeQuotesResponse.linkedAccounts.map {
                LinkedAccountStatusRefViewModel(linkedAccountStatusRef: $0)
            }
            tradeQuoteViewModels = tradeQuotesResponse.tradeQuotes.map {
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
