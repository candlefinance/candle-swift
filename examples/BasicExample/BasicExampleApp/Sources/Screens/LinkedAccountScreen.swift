import Candle
import SwiftUI

struct LinkedAccountScreen: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var showLinkSheet: Bool
    @Binding var error: (title: String, message: String)?
    @Binding var linkedAccounts: [Candle.Models.LinkedAccount]

    @State private(set) var linkedAccount: Candle.Models.LinkedAccount
    @State private var isUnlinking = false

    var body: some View {
        List {
            InfoHeader(
                logo: .url(linkedAccount.service.logoURLValue),
                title: linkedAccount.title,
                badges: [linkedAccount.badge],
            )

            if case .active(let activeDetails) = linkedAccount.details {
                if activeDetails.emailAddress != nil || activeDetails.accountOpened != nil
                    || activeDetails.username != nil
                {
                    Section(header: Text("Details")) {
                        if let username = activeDetails.username {
                            InfoRow(symbol: .person, title: "Username", value: username)
                        }
                        if let emailAddress = activeDetails.emailAddress {
                            InfoRow(symbol: .envelope, title: "Email Address", value: emailAddress)
                        }
                        if let accountOpened = activeDetails.accountOpened {
                            let accountOpenedDate = ISO8601DateFormatter.candle.date(
                                from: accountOpened
                            )
                            InfoRow(
                                symbol: .calendar,
                                title: "Account Opened",
                                value: accountOpenedDate?
                                    .formatted(date: .complete, time: .complete) ?? accountOpened
                            )
                        }
                    }
                }
            }

            Section(header: Text("Metadata")) {
                InfoRow(
                    symbol: .person,
                    title: "Service User ID",
                    value: linkedAccount.serviceUserID
                )
                InfoRow(
                    symbol: .link,
                    title: "Linked Account ID",
                    value: linkedAccount.linkedAccountID
                )
            }

            Section(header: Text("Actions")) {
                Button(isUnlinking ? "Unlinking..." : "Unlink Account") {
                    Task { await unlinkAccount() }
                }
                .disabled(isUnlinking).tint(.red)
            }
        }
        .toolbar {
            if case .inactive = linkedAccount.details {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Re-Link") { showLinkSheet = true }
                }
            }
        }
        .refreshable { await getLinkedAccount() }
    }

    private func getLinkedAccount() async {
        do {
            linkedAccount = try await Candle.Client.shared.getLinkedAccount(ref: linkedAccount.ref)
        } catch {
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

    private func unlinkAccount() async {
        isUnlinking = true
        defer { isUnlinking = false }

        do {
            try await Candle.Client.shared.unlinkAccount(
                ref: .init(linkedAccountID: linkedAccount.id)
            )
            linkedAccounts = try await Candle.Client.shared.getLinkedAccounts()
            dismiss()
        } catch let error as Candle.Models.UnlinkAccount.Error {
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
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            case .gatewayTimeout(let payload):
                switch payload.kind {
                case .unavailable_proxy:
                    self.error = (title: "Proxy Unavailable", message: payload.message)
                }
            }
        } catch { self.error = (title: "Network Error", message: error.localizedDescription) }
    }
}

private let previewSandboxService = Candle.Models.Service(
    id: .sandbox,
    displayName: "Sandbox",
    logoURL: "https://institution-logos.s3.us-east-1.amazonaws.com/sandbox.png",
    thumbhash: nil,
    accentColor: "#FF5941",
)

#Preview {
    LinkedAccountScreen(
        showLinkSheet: .constant(false),
        error: .constant(nil),
        linkedAccounts: .constant([]),
        linkedAccount: .init(
            linkedAccountID: "00000000-0000-0000-0000-000000000000",
            service: previewSandboxService,
            serviceUserID: "1234567890",
            details: .active(
                .init(
                    accountOpened: "2016-02-01T08:34:20.000+08:00",
                    username: "johnny",
                    emailAddress: "john@apple.com",
                    legalName: "John Appleseed",
                )
            )
        ),
    )
}

#Preview {
    LinkedAccountScreen(
        showLinkSheet: .constant(false),
        error: .constant(nil),
        linkedAccounts: .constant([]),
        linkedAccount: .init(
            linkedAccountID: "00000000-0000-0000-0000-000000000000",
            service: previewSandboxService,
            serviceUserID: "1234567890",
            details: .inactive(.init())
        )
    )
}
