import Candle
import SwiftUI

struct TradesScreen: View {

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

    @Environment(CandleClient.self) private var client

    @State private var errorMessage: String? = nil
    @State private var trades = [TradeViewModel]()
    @State private var isLoading = false

    @State private var dateTimeSpan: SupportedSpan? = nil
    @State private var lostAssetKind: Models.GetTrades.Input.Query.LostAssetKindPayload? = nil
    @State private var gainedAssetKind: Models.GetTrades.Input.Query.GainedAssetKindPayload? = nil
    @State private var counterpartyKind: Models.GetTrades.Input.Query.CounterpartyKindPayload? = nil

    @State private var selectedLinkedAccountIDs: [Models.LinkedAccountID] = []
    @State private var searchText = ""

    let linkedAccounts: [Models.LinkedAccount]

    var tradesQuery: Models.GetTrades.Input.Query {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            dateTimeSpan: dateTimeSpan?.rawValue,
            gainedAssetKind: gainedAssetKind,
            lostAssetKind: lostAssetKind,
            counterpartyKind: counterpartyKind
        )
    }

    var filteredTrades: [TradeViewModel] {
        guard !searchText.isEmpty else { return trades }

        return trades.filter {
            $0.searchTokens.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
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
                List {
                    ForEach(filteredTrades) { trade in
                        NavigationLink(destination: ItemScreen(viewModel: trade)) {
                            ItemRow(viewModel: trade)
                        }
                    }
                }
                .overlay {
                    if filteredTrades.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
                .searchable(text: $searchText, prompt: Text("Search by asset or counterparty"))
                .navigationTitle("Trades")
                .refreshable {
                    await loadTrades(query: tradesQuery, showLoading: false)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            EnumMenu(name: "Date/Time Span", selectedCase: $dateTimeSpan)
                            EnumMenu(name: "Lost Asset Kind", selectedCase: $lostAssetKind)
                            EnumMenu(
                                name: "Gained Asset Kind", selectedCase: $gainedAssetKind)
                            EnumMenu(
                                name: "Counterparty Kind", selectedCase: $counterpartyKind)
                            LinkedAccountsMenu(
                                linkedAccounts: linkedAccounts,
                                selectedLinkedAccountIDs: $selectedLinkedAccountIDs
                            )
                        } label: {
                            Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                        }
                    }
                }
            }
        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"), message: Text(errorMessage ?? "No Message"),
                dismissButton: .cancel(Text("OK"), action: { errorMessage = nil }))
        }
        .task(id: tradesQuery) {
            await loadTrades(query: tradesQuery)
        }
        .sensoryFeedback(.error, trigger: errorMessage) { $1 != nil }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(.extraLarge)
    }

    private func loadTrades(
        query: Models.GetTrades.Input.Query, showLoading: Bool = true
    ) async {
        guard !isLoading else { return }
        isLoading = showLoading
        defer { isLoading = false }
        do {
            trades = try await client.getTrades(query: query).map {
                TradeViewModel(client: client, trade: $0)
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
