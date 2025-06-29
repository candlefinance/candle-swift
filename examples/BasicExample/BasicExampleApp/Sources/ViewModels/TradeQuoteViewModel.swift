import Candle
import Foundation

struct TradeQuoteViewModel {
    let tradeQuote: Models.TradeQuote
}

extension TradeQuoteViewModel: ItemViewModel {
    var title: String {
        switch tradeQuote.gained {
        case .TransportAsset(let transportAsset):
            return transportAsset.name
        case .MarketTradeAsset(let marketAsset):
            return marketAsset.name

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch tradeQuote.lost {
            case .TransportAsset(let transportAsset):
                return transportAsset.name
            case .MarketTradeAsset(let marketAsset):
                return marketAsset.name

            case .FiatAsset, .NothingAsset, .OtherAsset:
                return "—"  // FIXME: Display something in these cases
            }
        }
    }

    // FIXME: Display counterparty (service) name instead?
    var subtitle: String {
        switch tradeQuote.gained {
        case .TransportAsset(let transportAsset):
            return transportAsset.service.name
        case .MarketTradeAsset(let marketAsset):
            return marketAsset.service.name

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch tradeQuote.lost {
            case .TransportAsset(let transportAsset):
                return transportAsset.service.name
            case .MarketTradeAsset(let marketAsset):
                return marketAsset.service.name

            case .FiatAsset, .NothingAsset, .OtherAsset:
                return "—"  // FIXME: Display something in these cases
            }
        }
    }

    var value: String {
        if case .FiatAsset(let fiatAsset) = tradeQuote.gained {
            return fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode))
        } else if case .FiatAsset(let fiatAsset) = tradeQuote.lost {
            return (-fiatAsset.amount).formatted(.currency(code: fiatAsset.currencyCode))
        } else {
            return "—"
        }
    }

    var logoURL: URL? {
        // FIXME: Log if URLs don't decode (or decode them earlier)
        switch tradeQuote.gained {
        case .TransportAsset(let transportAsset):
            return URL(string: transportAsset.imageURL)
        case .MarketTradeAsset(let marketAsset):
            return URL(string: marketAsset.logoURL)

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch tradeQuote.lost {
            case .TransportAsset(let transportAsset):
                return URL(string: transportAsset.imageURL)
            case .MarketTradeAsset(let marketAsset):
                return URL(string: marketAsset.logoURL)

            case .FiatAsset, .NothingAsset, .OtherAsset:
                return nil  // FIXME: Display something in these cases
            }
        }
    }

    var context: Models.TradeQuoteContext {
        let linkedAccountID: String
        switch tradeQuote.gained {
        case .TransportAsset(let transportAsset):
            linkedAccountID = transportAsset.linkedAccountID
        case .MarketTradeAsset(let marketAsset):
            linkedAccountID = marketAsset.linkedAccountID

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch tradeQuote.lost {
            case .TransportAsset(let transportAsset):
                linkedAccountID = transportAsset.linkedAccountID
            case .MarketTradeAsset(let marketAsset):
                linkedAccountID = marketAsset.linkedAccountID

            case .FiatAsset, .NothingAsset, .OtherAsset:
                linkedAccountID = "FIXME"  // FIXME: Do something in these cases
            }
        }

        return .init(linkedAccountID: linkedAccountID, context: tradeQuote.context)
    }

    var details: [Detail] {
        return TradeAssetViewModel(tradeAsset: tradeQuote.lost).details.map {
            Detail(label: "Lost: " + $0.label, value: $0.value, iconName: $0.iconName)
        }
            + TradeAssetViewModel(tradeAsset: tradeQuote.gained).details.map {
                Detail(label: "Gained: " + $0.label, value: $0.value, iconName: $0.iconName)
            } + [
                Detail(
                    label: "Expires At",
                    value: tradeQuote.expirationDateTime,
                    iconName: "number"
                )
            ]
    }

    func reload() async throws(ItemReloadError) {
        // FIXME: Implement this or throw error somehow
    }
}

extension TradeQuoteViewModel: Identifiable {
    var id: String { tradeQuote.id }
}
