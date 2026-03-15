import Candle
import SwiftUI

struct LinkedAccountScreen: View {
    @Binding var showLinkSheet: Bool
    @Binding var error: (title: String, message: String)?

    @State private(set) var linkedAccount: Candle.Models.LinkedAccount

    var body: some View {
        List {
            InfoHeader(
                logo: .url(linkedAccount.service.logoURL),
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
}

#Preview {
    LinkedAccountScreen(
        showLinkSheet: .constant(false),
        error: .constant(nil),
        linkedAccount: .init(
            linkedAccountID: "00000000-0000-0000-0000-000000000000",
            service: .sandbox,
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
        linkedAccount: .init(
            linkedAccountID: "00000000-0000-0000-0000-000000000000",
            service: .sandbox,
            serviceUserID: "1234567890",
            details: .inactive(.init())
        )
    )
}
