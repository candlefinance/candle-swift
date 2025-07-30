import Candle
import SwiftUI

struct AssetAccountViewModel {
    let client: CandleClient
    var assetAccount: Models.AssetAccount
}

extension AssetAccountViewModel: ItemViewModel {
    var title: String {
        assetAccount.nickname
    }

    var subtitle: String {
        switch assetAccount {
        case .FiatAccount(let fiatAccount):
            return fiatAccount.service.name
        case .MarketAccount(let marketAccount):
            return marketAccount.service.name
        case .TransportAccount(let transportAccount):
            return transportAccount.service.name
        }
    }

    var value: String {
        switch assetAccount {
        case .FiatAccount(let fiatAccount):
            fiatAccount.balance?.formatted(.currency(code: fiatAccount.currencyCode))
                ?? "Fiat"
        case .MarketAccount(let marketAccount):
            // FIXME: Expose other information
            marketAccount.assetKind.rawValue
        case .TransportAccount(let transportAccount):
            // FIXME: Expose other information
            transportAccount.assetKind.rawValue
        }
    }

    var logoURL: URL? {
        switch assetAccount {
        case .FiatAccount(let fiatAccount):
            return fiatAccount.service.logoURL
        case .MarketAccount(let marketAccount):
            return marketAccount.service.logoURL
        case .TransportAccount(let transportAccount):
            return transportAccount.service.logoURL
        }
    }

    var accountKind: String {
        switch assetAccount {
        case .FiatAccount(let fiatAccount):
            fiatAccount.accountKind.rawValue
        case .MarketAccount(let marketAccount):
            marketAccount.accountKind.rawValue
        case .TransportAccount(let transportAccount):
            transportAccount.accountKind.rawValue
        }
    }

    var details: [Detail] {
        let detailsItems: [Detail]
        switch assetAccount {
        case .FiatAccount(let fiatAccount):
            let wireItems =
                fiatAccount.wire.map { wire -> [Detail] in
                    [
                        .init(
                            label: "Routing Number",
                            value: wire.routingNumber,
                            iconName: "arrow.left.arrow.right"
                        ),
                        .init(
                            label: "Account Number",
                            value: wire.accountNumber,
                            iconName: "creditcard.fill"
                        ),
                    ]
                } ?? []

            let achItems =
                fiatAccount.ach.map { ach -> [Detail] in
                    [
                        .init(
                            label: "Account Kind",
                            value: ach.accountKind.rawValue,
                            iconName: "doc.text.fill"
                        ),
                        .init(
                            label: "Account Number",
                            value: ach.accountNumber,
                            iconName: "creditcard.fill"
                        ),
                        .init(
                            label: "Routing Number",
                            value: ach.routingNumber,
                            iconName: "arrow.left.arrow.right"
                        ),
                    ]
                } ?? []

            detailsItems =
                [
                    .init(
                        label: "Asset Kind",
                        value: fiatAccount.assetKind.rawValue,
                        iconName: "info.circle"
                    ),
                    .init(
                        label: "Service Account ID",
                        value: fiatAccount.serviceAccountID,
                        iconName: "barcode"
                    ),
                    // FIXME: Display currencyCode regardless (or don't return it?)
                    fiatAccount.balance.map {
                        .init(
                            label: "Balance",
                            value: $0.formatted(
                                .currency(code: fiatAccount.currencyCode)),
                            iconName: "info.circle"
                        )
                    },
                    .init(
                        label: "Linked Account ID",
                        value: fiatAccount.linkedAccountID,
                        iconName: "info.circle"
                    ),
                    .init(
                        label: "Service",
                        value: fiatAccount.service.rawValue,
                        iconName: "info.circle"
                    ),
                    //                .init(
                    //                    label: "Secondary References",
                    //                    value: account.secondaryRefs.map {
                    //                        "\($0.linkedAccountID) \($0.serviceFiatHoldingAccountID) \($0.refKind.rawValue)"
                    //                    }.joined(separator: ", "),
                    //                    iconName: "link"
                    //                ),
                ].compactMap { $0 }
                + wireItems.map {
                    Detail(
                        label: "Wire: " + $0.label, value: $0.value, iconName: $0.iconName)
                }
                + achItems.map {
                    Detail(
                        label: "ACH: " + $0.label, value: $0.value, iconName: $0.iconName)
                }
        case .MarketAccount(let marketAccount):
            detailsItems = [
                .init(
                    label: "Asset Kind",
                    value: marketAccount.assetKind.rawValue,
                    iconName: "info.circle"
                ),
                .init(
                    label: "Service Account ID",
                    value: marketAccount.serviceAccountID,
                    iconName: "barcode"
                ),
                .init(
                    label: "Linked Account ID",
                    value: marketAccount.linkedAccountID,
                    iconName: "info.circle"
                ),
            ]
        case .TransportAccount(let transportAccount):
            detailsItems = [
                .init(
                    label: "Asset Kind", value: transportAccount.assetKind.rawValue,
                    iconName: "icon.circle"
                ),
                .init(
                    label: "Service Account ID", value: transportAccount.serviceAccountID,
                    iconName: "barcode"
                ),
                .init(
                    label: "Linked Account ID", value: transportAccount.linkedAccountID,
                    iconName: "info.circle"
                ),
            ]
        }
        return [
            .init(
                label: "Nickname",
                value: assetAccount.nickname,
                iconName: "person.fill"
            ),
            .init(
                label: "Legal Account Kind",
                value: accountKind,
                iconName: "info.circle"
            ),
        ]
            + detailsItems.map {
                Detail(
                    label: "Details: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
    }

    mutating func reload() async throws(ItemReloadError) {
        do {
            assetAccount = try await client.getAssetAccount(ref: assetAccount.ref)
        } catch {
            switch error {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    throw .init(title: "User Not Found", description: payload.message)
                case .notFound_linkedAccount:
                    throw .init(title: "Linked Account Not Found", description: payload.message)
                case .notFound_assetAccount:
                    throw .init(title: "Asset Account Not Found", description: payload.message)
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
                case .badAuthorization_linkedAccount:
                    throw .init(
                        title: "Bad Linked Account Authorization", description: payload.message)
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

extension AssetAccountViewModel: Identifiable {
    var id: String { assetAccount.id }
}
