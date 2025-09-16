import Candle
import SwiftUI

struct TradesScreen: View {

    private enum _State {
        case initial
        case loading
        case normal(Candle.Models.TradesResponse)
    }

    // FIXME: Support dynamic span values like the SDK
    private enum SupportedSpan: String, CaseIterable, Identifiable {
        case pt3h = "PT3H"
        case pt6h = "PT6H"
        case pt12h = "PT12H"
        case p1d = "P1D"
        case p7d = "P7D"
        case p1m = "P1M"
        case p6m = "P6M"
        case p1y = "P1Y"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .pt3h: return "3 Hours"
            case .pt6h: return "6 Hours"
            case .pt12h: return "12 Hours"
            case .p1d: return "1 Day"
            case .p7d: return "7 Days"
            case .p1m: return "1 Month"
            case .p6m: return "6 Months"
            case .p1y: return "1 Year"
            }
        }
    }

    @Binding var error: (title: String, message: String)?

    @State private var state: _State = .initial
    @State private var dateTimeSpan: SupportedSpan? = nil
    @State private var lostAssetKind: Candle.Models.GetTrades.Input.Query.LostAssetKindPayload? =
        nil
    @State private var gainedAssetKind:
        Candle.Models.GetTrades.Input.Query.GainedAssetKindPayload? = nil
    @State private var counterpartyKind:
        Candle.Models.GetTrades.Input.Query.CounterpartyKindPayload? = nil
    @State private var selectedLinkedAccountIDs: [Candle.Models.LinkedAccountID] = []

    @State private var searchText = ""
    @State private var showTradeQuotes: Bool = false
    @State private var tradeQuoteToExecute: Candle.Models.TradeQuote? = nil
    @State private var newTrade: Candle.Models.Trade? = nil

    let linkedAccounts: [Candle.Models.LinkedAccount]

    var tradesQuery: Candle.Models.GetTrades.Input.Query {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            dateTimeSpan: dateTimeSpan?.rawValue,
            gainedAssetKind: gainedAssetKind,
            lostAssetKind: lostAssetKind,
            counterpartyKind: counterpartyKind
        )
    }

    var body: some View {
        List {
            Section(header: Text("Linked Accounts")) {
                switch state {
                case .initial:
                    ContentUnavailableView(
                        "Connection Error",
                        systemImage: "network.slash",
                        description: Text("Check your connection and pull to refresh.")
                    )
                case .loading:
                    ProgressView { Text("Loading...") }
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                case .normal(let tradesResponse):
                    if tradesResponse.linkedAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Linked Accounts",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text("Try changing your filters or linking more services.")
                        )
                    } else {
                        ForEach(tradesResponse.linkedAccounts) { linkedAccountStatusRef in
                            // FIXME: Show linkedAccountID too
                            ItemRow(
                                title: linkedAccountStatusRef.service.description,
                                subtitle: linkedAccountStatusRef.serviceUserID,
                                value: linkedAccountStatusRef.state.description,
                                logoURL: linkedAccountStatusRef.service.logoURL
                            )
                        }
                    }
                }
            }
            Section(header: Text("Trades")) {
                switch state {
                case .initial:
                    ContentUnavailableView(
                        "Connection Error",
                        systemImage: "network.slash",
                        description: Text("Check your connection and pull to refresh.")
                    )
                case .loading:
                    ProgressView { Text("Loading...") }
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                case .normal(let tradesResponse):
                    if tradesResponse.trades.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        let filteredTrades =
                            searchText.isEmpty
                            ? tradesResponse.trades
                            : tradesResponse.trades.filter {
                                $0.searchTokens.contains {
                                    $0.localizedCaseInsensitiveContains(searchText)
                                }
                            }
                        ForEach(filteredTrades) { trade in
                            NavigationLink(destination: TradeScreen(error: $error, trade: trade)) {
                                ItemRow(
                                    title: trade.formattedTitle,
                                    subtitle: trade.formattedSubtitle,
                                    value: trade.formattedValue,
                                    logoURL: trade.logoURL
                                )
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: Text("Search by asset or counterparty"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    EnumMenu(name: "Date/Time Span", selectedCase: $dateTimeSpan)
                    EnumMenu(name: "Lost Asset Kind", selectedCase: $lostAssetKind)
                    EnumMenu(name: "Gained Asset Kind", selectedCase: $gainedAssetKind)
                    EnumMenu(name: "Counterparty Kind", selectedCase: $counterpartyKind)
                    LinkedAccountsMenu(
                        linkedAccounts: linkedAccounts,
                        selectedLinkedAccountIDs: $selectedLinkedAccountIDs
                    )
                } label: {
                    Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showTradeQuotes = true }) {
                    Label("Link", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Trades")
        .navigationDestination(item: $newTrade) { newTrade in
            TradeScreen(error: $error, trade: newTrade)
        }
        .task { if case .initial = state { await getTrades() } }
        .onChange(of: dateTimeSpan) { Task { await getTrades() } }
        .onChange(of: lostAssetKind) { Task { await getTrades() } }
        .onChange(of: gainedAssetKind) { Task { await getTrades() } }
        .onChange(of: counterpartyKind) { Task { await getTrades() } }
        .onChange(of: selectedLinkedAccountIDs) { Task { await getTrades() } }
        .onChange(of: linkedAccounts) {
            selectedLinkedAccountIDs = []
            Task { await getTrades() }
        }
        .refreshable { await getTrades(showLoading: false) }
        .sheet(isPresented: $showTradeQuotes) {
            NavigationStack {
                TradeQuotesRequestScreen(
                    error: $error,
                    tradeQuoteToExecute: $tradeQuoteToExecute,
                    linkedAccounts: linkedAccounts
                )
            }
            .candleTradeExecutionSheet(item: $tradeQuoteToExecute) { result in
                switch result {
                case .success(let trade):
                    newTrade = trade
                    showTradeQuotes = false

                case .failure: break
                // FIXME: Show error in snackbar?
                }
            }
        }
    }

    private func getTrades(showLoading: Bool = true) async {
        if showLoading { state = .loading }

        do {
            let tradesResponse = try await Candle.Client.shared.getTrades(query: tradesQuery)
            state = .normal(tradesResponse)
        } catch {
            if showLoading { state = .initial }

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
            }
        }
    }
}

#Preview { TradesScreen(error: .constant(nil), linkedAccounts: []) }
