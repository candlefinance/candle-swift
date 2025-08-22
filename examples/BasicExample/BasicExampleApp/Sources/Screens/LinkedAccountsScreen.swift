import Candle
import SwiftUI

struct LinkedAccountsScreen: View {
    private enum _State {
        case initial
        case loading
        case normal
    }

    @Environment(CandleClient.self) private var client
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("com.trycandle.candle.show_onboarding.2", store: .standard) private
        var showOnboarding = true

    @Binding var linkedAccounts: [Models.LinkedAccount]
    @Binding var error: (title: String, message: String)?

    @State private var state: _State = .initial

    @State private var showDeleteConfirmation = false
    @State private var showLinkSheet = false
    @State private var showSDKVersion = false

    @State private var accountToUnlink: Models.LinkedAccount? = nil
    @State private var newLinkedAccount: Models.LinkedAccount? = nil

    var sdkVersion: String {
        // FIXME: Get the version of the SDK dependency itself
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { return "Unknown" }

        return appVersion
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
                    ProgressView { Text("Loading…") }.frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                case .normal:
                    if linkedAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Linked Accounts",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text("Link a service to get started")
                        )
                        .onTapGesture { showLinkSheet = true }
                    } else {
                        ForEach(linkedAccounts) { linkedAccount in
                            NavigationLink(
                                destination: LinkedAccountScreen(
                                    showLinkSheet: $showLinkSheet,
                                    error: $error,
                                    linkedAccount: linkedAccount
                                )
                            ) {
                                ItemRow(
                                    title: linkedAccount.service.description,
                                    subtitle: linkedAccount.formattedSubtitle,
                                    value: "",
                                    logoURL: linkedAccount.service.logoURL
                                )
                            }
                            .swipeActions {
                                if case .InactiveLinkedAccountDetails = linkedAccount.details {
                                    Button("Re-Link") { showLinkSheet = true }.tint(.green)
                                }
                                Button("Unlink") { accountToUnlink = linkedAccount }.tint(.red)
                            }
                        }
                    }
                }
            }
        }
        .task(id: showOnboarding) {
            if case .initial = state, !showOnboarding { await getLinkedAccounts() }
        }
        .refreshable { await getLinkedAccounts(showLoading: false) }
        .confirmationDialog(
            "Are You Sure?",
            isPresented: .constant(accountToUnlink != nil),
            titleVisibility: .visible
        ) {
            Button("Unlink Account", role: .destructive, action: { Task { await unlinkAccount() } })
            Button("Cancel", role: .cancel) { accountToUnlink = nil }
        } message: {
            Text(
                "You will no longer be able to view asset accounts or trades, retrieve trade quotes, or execute trades using this account."
            )
        }
        .navigationTitle("Services")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SettingsMenu(
                    showOnboarding: $showOnboarding,
                    showDeleteConfirmation: $showDeleteConfirmation,
                    showSDKVersion: $showSDKVersion
                )
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showLinkSheet = true }) {
                    Label("Link", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationDestination(item: $newLinkedAccount) { newLinkedAccount in
            LinkedAccountScreen(
                showLinkSheet: $showLinkSheet,
                error: $error,
                linkedAccount: newLinkedAccount
            )
        }
        .confirmationDialog(
            "Delete User?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete User", role: .destructive, action: { Task { await deleteUser() } })
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Proceed with caution! This action is permanent and cannot be reverted")
        }
        .alert(isPresented: $showSDKVersion) {
            Alert(
                title: Text("Candle SDK Version"),
                message: Text(sdkVersion),
                dismissButton: .cancel(Text("OK"), action: { showSDKVersion = false })
            )
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingScreen(
                error: $error,
                photos: [
                    .init(resource: .link1), .init(resource: .link7), .init(resource: .link2),
                    .init(resource: .link6), .init(resource: .link3), .init(resource: .link4),
                    .init(resource: .link5),
                ],
                title: "Welcome to",
                product: "Candle",
                caption: "Explore the functionality of the Candle SDK",
                ctaText: "Get Started"
            )
        }
        .candleLinkSheet(
            isPresented: $showLinkSheet,
            customerName: "Acme Inc",
            services: .supported + [.sandbox],
            presentationStyle: .fullScreen,
            presentationBackground: AnyShapeStyle(.thickMaterial)
        ) { linkedAccount in
            newLinkedAccount = linkedAccount
            Task { await getLinkedAccounts() }
        }
        .sensoryFeedback(.selection, trigger: showOnboarding)
    }

    private func getLinkedAccounts(showLoading: Bool = true) async {
        if showLoading { state = .loading }

        do {
            linkedAccounts = try await client.getLinkedAccounts()
            state = .normal
        } catch {
            if showLoading { state = .initial }

            switch error {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    self.error = (title: "User Not Found", message: payload.message)
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
            case .sessionError(let sessionError): self.error = sessionError.formatted
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            }
        }
    }

    private func unlinkAccount() async {
        guard let accountToUnlink else {
            error = (title: "Internal Inconsistency", message: "No account to unlink")
            return
        }
        self.accountToUnlink = nil

        state = .loading

        do {
            try await client.unlinkAccount(path: .init(linkedAccountID: accountToUnlink.id))
            await getLinkedAccounts()
        } catch {
            state = .initial

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
            case .conflict(let payload):
                switch payload.kind {
                case .alreadyUnlinked_linkedAccount:
                    self.error = (
                        title: "Linked Account Already Unlinked", message: payload.message
                    )
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
            case .sessionError(let sessionError): self.error = sessionError.formatted
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            }
        }
    }

    private func deleteUser() async {
        state = .loading

        do {
            try await client.deleteUser()
            await getLinkedAccounts()
        } catch {
            state = .initial

            switch error {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    self.error = (title: "User Not Found", message: payload.message)
                case .notFound_app: self.error = (title: "App Not Found", message: payload.message)
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
                case .badAuthorization_app:
                    self.error = (title: "Bad App Authorization", message: payload.message)
                }
            case .forbidden(let payload):
                switch payload.kind {
                case .disabledPendingPayment_app:
                    self.error = (title: "App Disabled Pending Payment", message: payload.message)
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
            case .sessionError(let sessionError): self.error = sessionError.formatted
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            }
        }
    }
}

#Preview {
    LinkedAccountsScreen(linkedAccounts: .constant([]), error: .constant(nil))
        .environment(CandleClient(appUser: .init(appKey: "", appSecret: "")))
}
