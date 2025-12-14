import Candle
import SwiftUI

struct TradeQuotesRequestScreen: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var tradeQuoteToExecute: Candle.Models.TradeQuote?

    @State var gainedAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest
    @State var lostAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest
    @State var counterpartyQuoteRequest: Candle.Models.CounterpartyQuoteRequest?

    @State private var selectedLinkedAccountIDs: [Candle.Models.LinkedAccountID] = []
    @State private var areRequested: Bool = false

    let linkedAccounts: [Candle.Models.LinkedAccount]
    let assetAccounts: [Candle.Models.AssetAccount]

    var tradeQuotesRequest: Candle.Models.TradeQuotesRequest {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            gained: gainedAssetQuoteRequest,
            lost: lostAssetQuoteRequest,
            counterparty: counterpartyQuoteRequest
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section(
                    header: QuoteRequestGroupHeader(
                        title: "Lost Asset",
                        badge: lostAssetQuoteRequest.badge
                    )
                ) {
                    TradeAssetQuoteRequestGroup(
                        tradeAssetQuoteRequest: $lostAssetQuoteRequest,
                        assetAccounts: assetAccounts
                    )
                }
                Section(
                    header: QuoteRequestGroupHeader(
                        title: "Gained Asset",
                        badge: gainedAssetQuoteRequest.badge
                    )
                ) {
                    TradeAssetQuoteRequestGroup(
                        tradeAssetQuoteRequest: $gainedAssetQuoteRequest,
                        assetAccounts: assetAccounts
                    )
                }

                if let counterpartyQuoteRequest {
                    Section(
                        header: QuoteRequestGroupHeader(
                            title: "Counterparty",
                            badge: counterpartyQuoteRequest.badge
                        )
                    ) {
                        CounterpartyQuoteRequestGroup(
                            counterpartyQuoteRequest: Binding(
                                get: { counterpartyQuoteRequest },
                                set: { self.counterpartyQuoteRequest = $0 }
                            )
                        )
                    }
                }
            }
            .navigationTitle("Trade Quotes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        LinkedAccountsMenu(
                            linkedAccounts: linkedAccounts,
                            selectedLinkedAccountIDs: $selectedLinkedAccountIDs
                        )
                    } label: {
                        Label("Filters", systemSymbol: .line3HorizontalDecreaseCircle)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Request") { areRequested = true }.bold()
                }
            }
            .navigationDestination(isPresented: $areRequested) {
                TradeQuotesScreen(
                    tradeQuoteToExecute: $tradeQuoteToExecute,
                    tradeQuotesRequest: tradeQuotesRequest
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
