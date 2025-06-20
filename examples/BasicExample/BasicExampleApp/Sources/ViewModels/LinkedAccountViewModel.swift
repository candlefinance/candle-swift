import Candle
import SwiftUI

struct LinkedAccountViewModel {
    let client: CandleClient
    var linkedAccount: Models.LinkedAccount
}

extension LinkedAccountViewModel: ItemViewModel {
    var title: String {
        linkedAccount.service.name
    }

    var subtitle: String {
        switch linkedAccount.details {
        case .ActiveLinkedAccountDetails(let activeDetails):
            return activeDetails.legalName
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            switch inactiveDetails.state {
            case .inactive: return "Inactive"
            case .unavailable: return "Unavailable"
            }
        }
    }

    var value: String {
        ""  // FIXME: Make value optional
    }

    var logoURL: URL? {
        linkedAccount.service.logoURL
    }

    var details: [Detail] {
        let detailsItems: [Detail]
        switch linkedAccount.details {
        case .ActiveLinkedAccountDetails(let activeDetails):
            detailsItems = [
                Detail(
                    label: "State",
                    value: activeDetails.state.rawValue,
                    iconName: "checkmark.circle"),
                Detail(
                    label: "Legal Name",
                    value: activeDetails.legalName,
                    iconName: "person.crop.circle"),
                activeDetails.username.map {
                    Detail(
                        label: "Username",
                        value: $0,
                        iconName: "person")
                },
                activeDetails.emailAddress.map {
                    Detail(
                        label: "Email Address",
                        value: $0,
                        iconName: "envelope")
                },
                activeDetails.accountOpened.map {
                    Detail(
                        label: "Account Opened",
                        value: $0.formattedToCustomDate,
                        iconName: "calendar")
                },
            ].compactMap { $0 }
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            detailsItems = [
                Detail(
                    label: "State",
                    value: inactiveDetails.state.rawValue,
                    iconName: "xmark.circle")
            ]
        }

        return [
            Detail(
                label: "Linked Account ID",
                value: linkedAccount.linkedAccountID,
                iconName: "link"),
            Detail(
                label: "Service User ID",
                value: linkedAccount.serviceUserID,
                iconName: "number"),
            Detail(
                label: "Service",
                value: linkedAccount.service.rawValue,
                iconName: "line.3.horizontal.decrease.circle"),
        ]
            + detailsItems.map {
                Detail(
                    label: "Details: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
    }

    mutating func reload() async throws(ItemReloadError) {
        do {
            linkedAccount = try await client.getLinkedAccount(ref: linkedAccount.ref)
        } catch {
            switch error {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    throw .init(title: "User Not Found", description: payload.message)
                case .notFound_linkedAccount:
                    throw .init(title: "Linked Account Not Found", description: payload.message)
                }
            case .unprocessableContent(let payload):
                switch payload.kind {
                case .schemaInvalid_request:
                    throw .init(title: "Request Schema Invalid", description: payload.message)
                }
            case .unauthorized(let payload):
                switch payload.kind {
                case .badAuthorization_user:
                    throw .init(title: "Bad User Authorization", description: payload.message)
                }
            case .internalServerError(let payload):
                switch payload.kind {
                case .unexpected:
                    throw .init(title: "Internal Server Error", description: payload.message)
                }
            case .unexpectedStatusCode(let statusCode):
                throw .init(
                    title: "Unexpected Status Code",
                    description: "Received response with status code \(statusCode)")
            case .sessionError(let sessionError):
                // FIXME: Switch on session errors
                throw .init(title: "Session Error", description: String(describing: sessionError))
            case .networkError(let errorDescription):
                throw .init(title: "Network Error", description: errorDescription)
            }
        }
    }
}

extension LinkedAccountViewModel: Identifiable {
    var id: String { linkedAccount.id }
}
