import Candle
import SwiftUI

// FIXME: Support refreshing on this screen as well
// FIXME: Show navigation bar even when loading
struct AssetAccountsScreen: View {
    @Environment(CandleClient.self) private var client

    @State var assetAccounts = [AssetAccountViewModel]()

    @State private var assetKind: Models.GetAssetAccounts.Input.Query.AssetKindPayload? = nil
    @State private var selectedLinkedAccountIDs: [Models.LinkedAccountID] = []

    @State private var errorMessage: String? = nil
    @State private var isLoading = false

    var assetAccountsQuery: Models.GetAssetAccounts.Input.Query {
        .init(
            linkedAccountIDs: selectedLinkedAccountIDs.isEmpty
                ? nil : selectedLinkedAccountIDs.joined(separator: ","),
            assetKind: assetKind
        )
    }

    let linkedAccounts: [Models.LinkedAccount]

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
                    ForEach(assetAccounts) { assetAccount in
                        NavigationLink(destination: ItemScreen(viewModel: assetAccount)) {
                            ItemRow(viewModel: assetAccount)
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
                .overlay {
                    if assetAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Asset Accounts",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text(
                                "Try changing your filters or linking more accounts."
                            )
                        )
                    }
                }
                .navigationTitle("Asset Accounts")
            }
        }
        .sensoryFeedback(.error, trigger: errorMessage) { $1 != nil }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"), message: Text(errorMessage ?? "No Message"),
                dismissButton: .cancel(Text("OK"), action: { errorMessage = nil }))
        }
        .task(id: assetAccountsQuery) {
            await loadAssetAccounts(query: assetAccountsQuery)
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(.extraLarge)
    }

    private func loadAssetAccounts(query: Models.GetAssetAccounts.Input.Query) async {
        defer { isLoading = false }
        do {
            isLoading = true
            assetAccounts = try await client.getAssetAccounts(query: query).map {
                AssetAccountViewModel(client: client, assetAccount: $0)
            }
        } catch {
            errorMessage = String(describing: error)
        }
    }
}

#Preview {
    AssetAccountsScreen(linkedAccounts: [])
}
