import Candle
import SwiftUI

struct AssetAccountsScreen: View {
    private enum _State {
        case initial
        case loading
        case normal(Candle.Models.AssetAccountsResponse)
    }
    @Binding var assetAccounts: [Candle.Models.AssetAccount]

    @State private var error: (title: String, message: String)?
    @State private var state: _State = .initial {
        didSet {
            guard case .normal(let assetAccountsResponse) = state else { return }
            assetAccounts = assetAccountsResponse.assetAccounts
        }
    }
    @State private var assetKind: Candle.Models.GetAssetAccounts.Input.Query.AssetKindPayload? = nil
    @State private var selectedLinkedAccountIDs: [Candle.Models.LinkedAccountID] = []

    let linkedAccounts: [Candle.Models.LinkedAccount]

    private var assetAccountsQuery: Candle.Models.GetAssetAccounts.Input.Query {
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
                case .initial:
                    ContentUnavailableView(
                        "Network Error",
                        systemSymbol: .networkSlash,
                        description: Text("Check your connection and pull to refresh.")
                    )
                case .loading:
                    ProgressView { Text("Loading...") }
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                case .normal(let assetAccountsResponse):
                    if assetAccountsResponse.linkedAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Linked Accounts",
                            systemSymbol: .exclamationmarkMagnifyingglass,
                            description: Text("Try changing your filters or linking more services.")
                        )
                    } else {
                        DisclosureGroup {
                            ForEach(assetAccountsResponse.linkedAccounts) {
                                linkedAccountStatusRef in
                                ItemRow(
                                    title: linkedAccountStatusRef.linkedAccountID,
                                    badges: [linkedAccountStatusRef.badge],
                                    value: linkedAccountStatusRef.serviceUserID,
                                    logo: .url(linkedAccountStatusRef.service.logoURL)
                                )
                            }
                        } label: {
                            VStack {
                                ForEach(assetAccountsResponse.linkedAccounts) {
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
            Section(header: Text("Asset Accounts")) {
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
                case .normal(let assetAccountsResponse):
                    if assetAccountsResponse.assetAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Asset Accounts",
                            systemSymbol: .exclamationmarkMagnifyingglass,
                            description: Text("Try changing your filters or linking more services.")
                        )
                    } else {
                        ForEach(assetAccountsResponse.assetAccounts) { assetAccount in
                            NavigationLink(
                                destination: AssetAccountScreen(
                                    error: $error,
                                    assetAccount: assetAccount
                                )
                            ) {
                                ItemRow(
                                    title: assetAccount.nickname,
                                    badges: [assetAccount.badge],
                                    value: assetAccount.value,
                                    logo: .url(assetAccount.service.logoURL)
                                )
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
                    Label("Filters", systemSymbol: .line3HorizontalDecreaseCircle)
                }
            }
        }
        .navigationTitle("Accounts").task { if case .initial = state { await getAssetAccounts() } }
        .onChange(of: assetKind) { Task { await getAssetAccounts() } }
        .onChange(of: selectedLinkedAccountIDs) { Task { await getAssetAccounts() } }
        .onChange(of: linkedAccounts) {
            selectedLinkedAccountIDs = []
            Task { await getAssetAccounts() }
        }
        .refreshable { await getAssetAccounts(showLoading: false) }
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text(error!.title),
                message: Text(error!.message),
                dismissButton: .cancel(Text("OK"), action: { error = nil })
            )
        }
    }

    private func getAssetAccounts(showLoading: Bool = true) async {
        if showLoading { state = .loading }

        do {
            let assetAccountsResponse = try await Candle.Client.shared.getAssetAccounts(
                query: assetAccountsQuery
            )
            state = .normal(assetAccountsResponse)
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
