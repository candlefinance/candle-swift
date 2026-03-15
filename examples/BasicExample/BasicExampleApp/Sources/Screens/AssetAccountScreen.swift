import Candle
import SwiftUI

struct AssetAccountScreen: View {
    @Binding var error: (title: String, message: String)?

    @State private(set) var assetAccount: Candle.Models.AssetAccount

    var body: some View {
        List {
            InfoHeader(
                logo: .url(assetAccount.service.logoURL),
                title: assetAccount.nickname,
                badges: [assetAccount.badge],
            )

            switch assetAccount {
            case .fiat(let fiatAccount):
                Section(header: Text("Details")) {
                    InfoRow(
                        symbol: .infoCircle,
                        title: "Account Kind",
                        value: fiatAccount.accountKind.description,
                    )

                    if let balance = fiatAccount.balance {
                        InfoRow(
                            symbol: .banknote,
                            title: "Balance",
                            value: balance.formatted(.currency(code: fiatAccount.currencyCode)),
                        )
                    } else {
                        InfoRow(
                            symbol: .banknote,
                            title: "Currency Code",
                            value: fiatAccount.currencyCode,
                        )
                    }
                }

                if let ach = fiatAccount.ach {
                    Section(header: Text("ACH")) {
                        InfoRow(
                            symbol: .docText,
                            title: "Account Kind",
                            value: ach.accountKind.description,
                        )
                        InfoRow(
                            symbol: .number,
                            title: "Account Number",
                            value: ach.accountNumber,
                        )
                        InfoRow(
                            symbol: .arrowLeftArrowRight,
                            title: "Routing Number",
                            value: ach.routingNumber,
                        )
                    }
                }

                if let wire = fiatAccount.wire {
                    Section(header: Text("Wire")) {
                        InfoRow(
                            symbol: .number,
                            title: "Account Number",
                            value: wire.accountNumber,
                        )
                        InfoRow(
                            symbol: .arrowLeftArrowRight,
                            title: "Routing Number",
                            value: wire.routingNumber,
                        )
                    }
                }

                Section(header: Text("Metadata")) {
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: fiatAccount.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: fiatAccount.linkedAccountID
                    )
                }
            case .crypto(let cryptoAccount):
                Section(header: Text("Details")) {
                    InfoRow(symbol: .tag, title: "Nickname", value: cryptoAccount.nickname, )
                    InfoRow(
                        symbol: .infoCircle,
                        title: "Account Kind",
                        value: cryptoAccount.accountKind.description,
                    )
                }
                Section(header: Text("Metadata")) {
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: cryptoAccount.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: cryptoAccount.linkedAccountID
                    )
                }
            case .stock(let stockAccount):
                Section(header: Text("Details")) {
                    InfoRow(symbol: .tag, title: "Nickname", value: stockAccount.nickname, )
                    InfoRow(
                        symbol: .infoCircle,
                        title: "Account Kind",
                        value: stockAccount.accountKind.description,
                    )
                }
                Section(header: Text("Metadata")) {
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: stockAccount.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: stockAccount.linkedAccountID
                    )
                }
            case .transport(let transportAccount):
                Section(header: Text("Details")) {
                    InfoRow(symbol: .tag, title: "Nickname", value: transportAccount.nickname, )
                    InfoRow(
                        symbol: .infoCircle,
                        title: "Account Kind",
                        value: transportAccount.accountKind.description,
                    )
                }
                Section(header: Text("Metadata")) {
                    InfoRow(
                        symbol: .buildingColumns,
                        title: "Service Account ID",
                        value: transportAccount.serviceAccountID
                    )
                    InfoRow(
                        symbol: .link,
                        title: "Linked Account ID",
                        value: transportAccount.linkedAccountID
                    )
                }
            }
        }
        .refreshable { await getAssetAccount() }
    }

    private func getAssetAccount() async {
        do {
            assetAccount = try await Candle.Client.shared.getAssetAccount(ref: assetAccount.ref)
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
            case .networkError(let errorDescription):
                self.error = (title: "Network Error", message: errorDescription)
            case .gatewayTimeout(let payload):
                switch payload.kind {
                case .unavailable_proxy:
                    self.error = (title: "Proxy Unavailable", message: payload.message)
                }
            }
        }
    }
}
