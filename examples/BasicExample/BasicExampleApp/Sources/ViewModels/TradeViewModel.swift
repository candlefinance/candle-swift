import Candle
import Foundation

struct TradeViewModel {
    let client: CandleClient
    var trade: Models.Trade

    var searchTokens: [String] {
        let counterpartyNames: [String]
        switch trade.counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            counterpartyNames = [merchantCounterparty.name]
        case .ServiceCounterparty:
            counterpartyNames = []
        case .UserCounterparty(let userCounterparty):
            counterpartyNames = [userCounterparty.username, userCounterparty.legalName]
        }

        let lostAssetNames: [String]
        switch trade.lost {
        case .MarketTradeAsset(let marketTradeAsset):
            lostAssetNames = [marketTradeAsset.symbol]  // FIXME: Add name
        case .FiatAsset, .TransportAsset, .OtherAsset, .NothingAsset:
            lostAssetNames = []
        }

        let gainedAssetNames: [String]
        switch trade.gained {
        case .MarketTradeAsset(let marketTradeAsset):
            gainedAssetNames = [marketTradeAsset.symbol]  // FIXME: Add name
        case .FiatAsset, .TransportAsset, .OtherAsset, .NothingAsset:
            gainedAssetNames = []
        }

        return counterpartyNames + lostAssetNames + gainedAssetNames
    }
}

extension TradeViewModel: ItemViewModel {
    var title: String {
        switch trade.counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            return merchantCounterparty.name
        case .UserCounterparty(let userCounterparty):
            return userCounterparty.legalName
        case .ServiceCounterparty(let serviceCounterparty):
            return serviceCounterparty.service.name
        }
    }

    var subtitle: String {
        trade.dateTime.formattedToCustomDate
    }

    var value: String {
        if case .FiatAsset(let fiatAsset) = trade.gained {
            return fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode))
        } else if case .FiatAsset(let fiatAsset) = trade.lost {
            return (-fiatAsset.amount).formatted(.currency(code: fiatAsset.currencyCode))
        } else {
            return "—"
        }
    }

    var logoURL: URL? {
        switch trade.counterparty {
        // FIXME: Log if URLs don't decode (or decode them earlier)
        case .MerchantCounterparty(let merchantCounterparty):
            return URL(string: merchantCounterparty.logoURL)
        case .UserCounterparty(let userCounterparty):
            return URL(string: userCounterparty.avatarURL)
        case .ServiceCounterparty(let serviceCounterparty):
            return serviceCounterparty.service.logoURL
        }
    }

    var details: [Detail] {
        let counterpartyDetailItems: [Detail]

        switch trade.counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            let locationDetailItems: [Detail]
            if let location = merchantCounterparty.location {
                locationDetailItems = [
                    Detail(
                        label: "Country",
                        value: location.countryCode,
                        iconName: "globe"
                    ),
                    Detail(
                        label: "Country Subdivision Code",
                        value: location.countrySubdivisionCode,
                        iconName: "mappin.and.ellipse"
                    ),
                    Detail(
                        label: "Locality Name",
                        value: location.localityName,
                        iconName: "building.columns"
                    ),
                ]
            } else {
                locationDetailItems = []
            }
            counterpartyDetailItems =
                [
                    Detail(
                        label: "Kind",
                        value: merchantCounterparty.kind.rawValue,
                        iconName: "link.circle"
                    ),
                    Detail(
                        label: "Name",
                        value: merchantCounterparty.name,
                        iconName: "link.circle"
                    ),
                    Detail(
                        label: "Logo URL",
                        value: merchantCounterparty.logoURL,
                        iconName: "link.circle"
                    ),
                ]
                + locationDetailItems.map {
                    Detail(
                        label: "Location: " + $0.label, value: $0.value, iconName: $0.iconName)
                }
        case .UserCounterparty(let userCounterparty):
            counterpartyDetailItems = [
                Detail(
                    label: "Kind",
                    value: userCounterparty.kind.rawValue,
                    iconName: "person.circle"
                ),
                Detail(
                    label: "Username",
                    value: userCounterparty.username,
                    iconName: "person.circle"
                ),
                Detail(
                    label: "Legal Name",
                    value: userCounterparty.legalName,
                    iconName: "person.circle"
                ),
                Detail(
                    label: "Avatar URL",
                    value: userCounterparty.avatarURL,
                    iconName: "person.circle"
                ),
            ]
        case .ServiceCounterparty(let serviceCounterparty):
            counterpartyDetailItems = [
                Detail(
                    label: "Kind",
                    value: serviceCounterparty.kind.rawValue,
                    iconName: "person.circle"
                ),
                Detail(
                    label: "Service",
                    value: serviceCounterparty.service.rawValue,
                    iconName: "person.circle"
                ),
            ]
        }

        func detailItems(for tradeAsset: Models.TradeAsset) -> [Detail] {
            switch tradeAsset {
            case .FiatAsset(let fiatAsset):
                return [
                    Detail(
                        label: "Asset Kind",
                        value: fiatAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    ),
                    Detail(
                        label: "Linked Account ID",
                        value: fiatAsset.linkedAccountID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service",
                        value: fiatAsset.service.rawValue,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service Account ID",
                        value: fiatAsset.serviceAccountID,
                        iconName: "number"
                    ),
                    fiatAsset.serviceTradeID.map {
                        Detail(
                            label: "Service Trade ID",
                            value: $0,
                            iconName: "number"
                        )
                    },
                    Detail(
                        label: "Amount",
                        value: fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode)),
                        iconName: "dollarsign.circle"
                    ),
                ].compactMap { $0 }
            case .MarketTradeAsset(let marketTradeAsset):
                return [
                    Detail(
                        label: "Asset Kind",
                        value: marketTradeAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    ),
                    Detail(
                        label: "Linked Account ID",
                        value: marketTradeAsset.linkedAccountID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service",
                        value: marketTradeAsset.service.rawValue,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service Account ID",
                        value: marketTradeAsset.serviceAccountID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service Trade ID",
                        value: marketTradeAsset.serviceTradeID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Serivce Asset ID",
                        value: marketTradeAsset.serviceAssetID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Symbol",
                        value: marketTradeAsset.symbol,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Amount",
                        value: marketTradeAsset.amount.formatted(),
                        iconName: "number"
                    ),
                    Detail(
                        label: "Color",
                        value: marketTradeAsset.color,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Name",
                        value: marketTradeAsset.name,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Logo URL",
                        value: marketTradeAsset.logoURL,
                        iconName: "number"
                    ),
                ]
            case .TransportAsset(let transportAsset):
                return [
                    Detail(
                        label: "Asset Kind",
                        value: transportAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    ),
                    Detail(
                        label: "Linked Account ID",
                        value: transportAsset.linkedAccountID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service",
                        value: transportAsset.service.rawValue,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service Trade ID",
                        value: transportAsset.serviceTradeID,
                        iconName: "number"
                    ),
                    Detail(
                        label: "Service Account ID",
                        value: transportAsset.serviceAccountID,
                        iconName: "number"
                    ),
                ]
            case .NothingAsset(let nothingAsset):
                return [
                    Detail(
                        label: "Asset Kind",
                        value: nothingAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    )
                ]
            case .OtherAsset(let otherAsset):
                return [
                    Detail(
                        label: "Asset Kind",
                        value: otherAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    )
                ]
            }
        }

        return [
            Detail(
                label: "Date & Time",
                value: trade.dateTime.formattedToCustomDate,
                iconName: "calendar"),
            Detail(
                label: "State",
                value: trade.state.rawValue,
                iconName: "list.bullet"),
        ]
            + counterpartyDetailItems.map {
                Detail(
                    label: "Counterparty: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
            + detailItems(for: trade.lost).map {
                Detail(label: "Lost: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
            + detailItems(for: trade.gained).map {
                Detail(label: "Gained: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
    }

    mutating func reload() async throws(ItemReloadError) {
        do {
            trade = try await client.getTrade(ref: trade.ref)
        } catch {
            switch error {
            case .notFound(let payload):
                switch payload.kind {
                case .notFound_user:
                    throw .init(title: "User Not Found", description: payload.message)
                case .notFound_linkedAccount:
                    throw .init(title: "Linked Account Not Found", description: payload.message)
                case .notFound_trade:
                    throw .init(title: "Trade Not Found", description: payload.message)
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

extension TradeViewModel: Identifiable {
    var id: String { trade.id }
}
