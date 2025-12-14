import Candle
import SwiftUI

struct TradeQuotesScreen: View {
    private enum _State {
        case initial
        case loading
        case normal(Candle.Models.TradeQuotesResponse)
    }

    @Environment(\.dismiss) private var dismiss

    @Binding var tradeQuoteToExecute: Candle.Models.TradeQuote?

    @State private var error: (title: String, message: String)?
    @State private var state: _State = .initial
    @State private var selectedLinkedAccountIDs: [Candle.Models.LinkedAccountID] = []

    let tradeQuotesRequest: Candle.Models.TradeQuotesRequest

    var body: some View {
        List {
            Section(header: Text("Linked Accounts")) {
                switch state {
                case .initial:
                    ContentUnavailableView(
                        "Network Error",
                        systemSymbol: .networkSlash,
                        description: Text("Check your connection and pull to refresh.")
                    )
                case .loading:
                    ProgressView { Text("Loading...") }
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)

                case .normal(let tradeQuotesResponse):
                    if tradeQuotesResponse.linkedAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Linked Accounts",
                            systemSymbol: .exclamationmarkMagnifyingglass,
                            description: Text("Try changing your filters or linking more services.")
                        )
                    } else {
                        DisclosureGroup {
                            ForEach(tradeQuotesResponse.linkedAccounts) { linkedAccountStatusRef in
                                ItemRow(
                                    title: linkedAccountStatusRef.linkedAccountID,
                                    badges: [linkedAccountStatusRef.badge],
                                    value: linkedAccountStatusRef.serviceUserID,
                                    logo: .url(linkedAccountStatusRef.service.logoURL)
                                )
                            }
                        } label: {
                            VStack {
                                ForEach(tradeQuotesResponse.linkedAccounts) {
                                    linkedAccountStatusRef in
                                    SummaryRow(
                                        badges: [linkedAccountStatusRef.badge],
                                        logo: .url(linkedAccountStatusRef.service.logoURL)
                                    )
                                }
                            }
                        }
                    }
                }
            }
            Section(header: Text("Trade Quotes")) {
                switch state {
                case .initial:
                    ContentUnavailableView(
                        "Network Error",
                        systemSymbol: .networkSlash,
                        description: Text("Check your connection and pull to refresh.")
                    )
                case .loading:
                    ProgressView { Text("Loading...") }
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)

                case .normal(let tradeQuotesResponse):
                    if tradeQuotesResponse.tradeQuotes.isEmpty {
                        ContentUnavailableView(
                            "No Trade Quotes",
                            systemSymbol: .exclamationmarkMagnifyingglass,
                            description: Text("Try changing your filters or linking more services.")
                        )
                    } else {
                        ForEach(tradeQuotesResponse.tradeQuotes) { tradeQuote in
                            NavigationLink(
                                destination: TradeQuoteScreen(
                                    error: $error,
                                    tradeQuoteToExecute: $tradeQuoteToExecute,
                                    tradeQuote: tradeQuote
                                )
                            ) {
                                ItemRow(
                                    title: tradeQuote.title,
                                    badges: tradeQuote.badges,
                                    value: tradeQuote.value,
                                    logo: .url(tradeQuote.logoURL),
                                )
                            }
                            .swipeActions {
                                Button("Execute") { tradeQuoteToExecute = tradeQuote }.tint(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Trade Quotes").refreshable { await getTradeQuotes(showLoading: false) }
        .task { if case .initial = state { await getTradeQuotes() } }
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text(error!.title),
                message: Text(error!.message),
                dismissButton: .cancel(Text("OK"), action: { error = nil })
            )
        }
    }

    private func getTradeQuotes(showLoading: Bool = true) async {
        if showLoading { state = .loading }

        do {
            let tradeQuotesResponse = try await Candle.Client.shared.getTradeQuotes(
                request: tradeQuotesRequest
            )
            state = .normal(tradeQuotesResponse)
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
