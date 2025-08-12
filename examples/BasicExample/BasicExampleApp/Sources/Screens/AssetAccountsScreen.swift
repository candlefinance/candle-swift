import Candle
import SwiftUI

struct AssetAccountsScreen: View {
    private enum _State {
        case initial
        case loading
        case normal(Models.AssetAccountsResponse)
    }

    @Environment(CandleClient.self) private var client

    @Binding var error: (title: String, message: String)?

    @State private var state: _State = .initial
    @State private var assetKind: Models.GetAssetAccounts.Input.Query.AssetKindPayload? = nil
    @State private var selectedLinkedAccountIDs: [Models.LinkedAccountID] = []

    let linkedAccounts: [Models.LinkedAccount]

    var assetAccountsQuery: Models.GetAssetAccounts.Input.Query {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            assetKind: assetKind
        )
    }

    var body: some View {
        List {
            Section(header: Text("Linked Accounts")) {
                switch state {
                case .initial, .loading:
                    ProgressView {
                        Text("Loading...")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                case .normal(let assetAccountsResponse):
                    if assetAccountsResponse.linkedAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Linked Accounts",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text(
                                "Try changing your filters or linking more services.")
                        )
                    } else {
                        ForEach(assetAccountsResponse.linkedAccounts) {
                            linkedAccountStatusRef in
                            // FIXME: Show linkedAccountID too
                            ItemRow(
                                title: linkedAccountStatusRef.service.description,
                                subtitle: linkedAccountStatusRef.serviceUserID,
                                value: linkedAccountStatusRef.state.description,
                                logoURL: linkedAccountStatusRef.service.logoURL)
                        }
                    }
                }
            }
            Section(header: Text("Asset Accounts")) {
                switch state {
                case .initial: Spacer()
                case .loading:
                    ProgressView {
                        Text("Loading...")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                case .normal(let assetAccountsResponse):
                    if assetAccountsResponse.assetAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Asset Accounts",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text(
                                "Try changing your filters or linking more services."
                            )
                        )
                    } else {
                        ForEach(assetAccountsResponse.assetAccounts) { assetAccount in
                            NavigationLink(
                                destination: AssetAccountScreen(
                                    error: $error, assetAccount: assetAccount)
                            ) {
                                switch assetAccount {
                                case .FiatAccount(let fiatAccount):
                                    ItemRow(
                                        title: fiatAccount.nickname,
                                        subtitle: fiatAccount.service.description,
                                        value: fiatAccount.balance?.formatted(
                                            .currency(code: fiatAccount.currencyCode))
                                            ?? fiatAccount.currencyCode,
                                        logoURL: fiatAccount.service.logoURL)
                                case .MarketAccount(let marketAccount):
                                    ItemRow(
                                        title: marketAccount.nickname,
                                        subtitle: marketAccount.service.description,
                                        value: marketAccount.assetKind.description,
                                        logoURL: marketAccount.service.logoURL)
                                case .TransportAccount(let transportAccount):
                                    ItemRow(
                                        title: transportAccount.nickname,
                                        subtitle: transportAccount.service.description,
                                        value: transportAccount.assetKind.description,
                                        logoURL: transportAccount.service.logoURL)
                                }
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    EnumMenu(name: "Asset Kind", selectedCase: $assetKind)
                    LinkedAccountsMenu(
                        linkedAccounts: linkedAccounts,
                        selectedLinkedAccountIDs: $selectedLinkedAccountIDs
                    )
                } label: {
                    Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
        }
        .navigationTitle("Accounts")
        .task { if case .initial = state { await getAssetAccounts() } }
        .onChange(of: assetKind) { Task { await getAssetAccounts() } }
        .onChange(of: selectedLinkedAccountIDs) { Task { await getAssetAccounts() } }
        .onChange(of: linkedAccounts) {
            selectedLinkedAccountIDs = []
            Task { await getAssetAccounts() }
        }
        .refreshable {
            await getAssetAccounts(showLoading: false)
        }
    }

    private func getAssetAccounts(showLoading: Bool = true) async {
        if showLoading {
            state = .loading
        }

        do {
            let assetAccountsResponse = try await client.getAssetAccounts(query: assetAccountsQuery)
            state = .normal(assetAccountsResponse)
        } catch {
            if showLoading {
                state = .initial
            }

            switch error {
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

#Preview {
    AssetAccountsScreen(
        error: .constant(nil),
        linkedAccounts: [],
    )
}
