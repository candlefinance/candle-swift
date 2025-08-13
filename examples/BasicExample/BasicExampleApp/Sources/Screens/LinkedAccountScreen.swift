import Candle
import SwiftUI

struct LinkedAccountScreen: View {
    @Environment(CandleClient.self) private var client

    @Binding var error: (title: String, message: String)?

    @State private(set) var linkedAccount: Models.LinkedAccount

    private var badgeText: String {
        switch linkedAccount.details {
        case .ActiveLinkedAccountDetails(let activeDetails):
            return activeDetails.state.description
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            return inactiveDetails.state.description
        }
    }

    private var badgeColor: Color {
        switch linkedAccount.details {
        case .ActiveLinkedAccountDetails: return .green
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            switch inactiveDetails.state {
            case .inactive: return .red
            case .unavailable: return .yellow
            }
        }
    }

    private var headerTitle: String? {
        if case .ActiveLinkedAccountDetails(let activeDetails) = linkedAccount
            .details
        {
            return activeDetails.legalName
        } else {
            return nil
        }
    }

    var body: some View {
        List {
            InfoHeader(
                logoURL: linkedAccount.service.logoURL,
                title: headerTitle,
                badgeText: badgeText,
                badgeColor: badgeColor)

            Section(header: Text("Metadata")) {
                InfoRow(
                    systemImage: "link",
                    title: "Linked Account ID",
                    value: linkedAccount.linkedAccountID
                )
                InfoRow(
                    systemImage: "number",
                    title: "Service User ID",
                    value: linkedAccount.serviceUserID
                )
            }

            if case .ActiveLinkedAccountDetails(let activeDetails) = linkedAccount.details {
                if activeDetails.emailAddress != nil || activeDetails.accountOpened != nil
                    || activeDetails.username != nil
                {
                    Section(header: Text("Details")) {
                        if let username = activeDetails.username {
                            InfoRow(
                                systemImage: "person",
                                title: "Username",
                                value: username
                            )
                        }
                        if let emailAddress = activeDetails.emailAddress {
                            InfoRow(
                                systemImage: "envelope",
                                title: "Email Address",
                                value: emailAddress
                            )
                        }
                        if let accountOpened = activeDetails.accountOpened {
                            let accountOpenedDate = ISO8601DateFormatter.candle.date(
                                from: accountOpened)
                            InfoRow(
                                systemImage: "calendar",
                                title: "Account Opened",
                                value: accountOpenedDate?.formatted(
                                    date: .complete, time: .complete) ?? accountOpened
                            )
                        }
                    }
                }
            }
        }
        .refreshable {
            await getLinkedAccount()
        }
    }

    private func getLinkedAccount() async {
        do {
            linkedAccount = try await client.getLinkedAccount(ref: linkedAccount.ref)
        } catch {
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
    LinkedAccountScreen(
        error: .constant(nil),
        linkedAccount: .init(
            linkedAccountID: "00000000-0000-0000-0000-000000000000",
            service: .sandbox,
            serviceUserID: "1234567890",
            details: .ActiveLinkedAccountDetails(
                .init(
                    state: .active,
                    accountOpened: "2016-02-01T08:34:20.000+08:00",
                    username: "johnny",
                    emailAddress: "john@apple.com",
                    legalName: "John Appleseed",
                ))
        ),
    ).environment(CandleClient(appUser: .init(appKey: "", appSecret: "")))
}

#Preview {
    LinkedAccountScreen(
        error: .constant(nil),
        linkedAccount: .init(
            linkedAccountID: "00000000-0000-0000-0000-000000000000",
            service: .sandbox,
            serviceUserID: "1234567890",
            details: .InactiveLinkedAccountDetails(
                .init(
                    state: .inactive,
                ))
        )
    ).environment(CandleClient(appUser: .init(appKey: "", appSecret: "")))
}
