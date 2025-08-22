import Candle
import SwiftUI

struct AssetAccountScreen: View {
    @Environment(CandleClient.self) private var client

    @Binding var error: (title: String, message: String)?

    @State private(set) var assetAccount: Models.AssetAccount

    private var badgeText: String {
        switch assetAccount {
        case .FiatAccount(let fiatAccount): return fiatAccount.assetKind.description
        case .MarketAccount(let marketAccount): return marketAccount.assetKind.description
        case .TransportAccount(let transportAccount): return transportAccount.assetKind.description
        }
    }

    private var badgeColor: Color {
        switch assetAccount {
        case .FiatAccount: return .green
        case .MarketAccount(let marketAccount):
            switch marketAccount.assetKind {
            case .crypto: return .orange
            case .stock: return .indigo
            }
        case .TransportAccount: return .black
        }
    }

    var body: some View {
        List {
            InfoHeader(
                logoURL: assetAccount.service.logoURL,
                title: assetAccount.nickname,
                badgeText: badgeText,
                badgeColor: badgeColor
            )

            switch assetAccount {
            case .FiatAccount(let fiatAccount):
                Section(header: Text("Metadata")) {
                    InfoRow(
                        systemImage: "link",
                        title: "Linked Account ID",
                        value: fiatAccount.linkedAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Account ID",
                        value: fiatAccount.serviceAccountID
                    )
                }

                Section(header: Text("Details")) {
                    InfoRow(
                        systemImage: "info.circle",
                        title: "Account Kind",
                        value: fiatAccount.accountKind.description,
                    )
                    if let balance = fiatAccount.balance {
                        InfoRow(
                            systemImage: "banknote",
                            title: "Balance",
                            value: balance.formatted(.currency(code: fiatAccount.currencyCode)),
                        )
                    } else {
                        InfoRow(
                            systemImage: "banknote",
                            title: "Currency Code",
                            value: fiatAccount.currencyCode,
                        )
                    }
                }

                if let ach = fiatAccount.ach {
                    Section(header: Text("ACH")) {
                        InfoRow(
                            systemImage: "text.document",
                            title: "Account Kind",
                            value: ach.accountKind.description,
                        )
                        InfoRow(
                            systemImage: "creditcard",
                            title: "Account Number",
                            value: ach.accountNumber,
                        )
                        InfoRow(
                            systemImage: "arrow.left.arrow.right",
                            title: "Routing Number",
                            value: ach.routingNumber,
                        )
                    }
                }

                if let wire = fiatAccount.wire {
                    Section(header: Text("Wire")) {
                        InfoRow(
                            systemImage: "arrow.left.arrow.right",
                            title: "Routing Number",
                            value: wire.routingNumber,
                        )
                        InfoRow(
                            systemImage: "creditcard",
                            title: "Account Number",
                            value: wire.accountNumber,
                        )
                    }
                }
            case .MarketAccount(let marketAccount):
                Section(header: Text("Metadata")) {
                    InfoRow(
                        systemImage: "link",
                        title: "Linked Account ID",
                        value: marketAccount.linkedAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Account ID",
                        value: marketAccount.serviceAccountID
                    )
                }
                Section(header: Text("Details")) {
                    InfoRow(
                        systemImage: "info.circle",
                        title: "Account Kind",
                        value: marketAccount.accountKind.description,
                    )
                }
            case .TransportAccount(let transportAccount):
                Section(header: Text("Metadata")) {
                    InfoRow(
                        systemImage: "link",
                        title: "Linked Account ID",
                        value: transportAccount.linkedAccountID
                    )
                    InfoRow(
                        systemImage: "number",
                        title: "Service Account ID",
                        value: transportAccount.serviceAccountID
                    )
                }
                Section(header: Text("Details")) {
                    InfoRow(
                        systemImage: "info.circle",
                        title: "Account Kind",
                        value: transportAccount.accountKind.description,
                    )
                }
            }
        }
        .refreshable { await getAssetAccount() }
    }

    private func getAssetAccount() async {
        do { assetAccount = try await client.getAssetAccount(ref: assetAccount.ref) } catch {
            switch error {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    self.error = (title: "User Not Found", message: payload.message)
                case .notFound_linkedAccount:
                    self.error = (title: "Linked Account Not Found", message: payload.message)
                case .notFound_assetAccount:
                    self.error = (title: "Asset Account Not Found", message: payload.message)
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
                case .badAuthorization_linkedAccount:
                    self.error = (
                        title: "Bad Linked Account Authorization", message: payload.message
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
}
