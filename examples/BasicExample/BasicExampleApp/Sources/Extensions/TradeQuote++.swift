import Candle
import Foundation

extension Models.TradeQuote {
    var formattedTitle: String {
        switch gained {
        case .TransportAsset(let transportAsset):
            return transportAsset.name
        case .MarketTradeAsset(let marketAsset):
            return marketAsset.name

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch lost {
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
    var formattedSubtitle: String {
        switch gained {
        case .TransportAsset(let transportAsset):
            return transportAsset.service.description
        case .MarketTradeAsset(let marketAsset):
            return marketAsset.service.description

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch lost {
            case .TransportAsset(let transportAsset):
                return transportAsset.service.description
            case .MarketTradeAsset(let marketAsset):
                return marketAsset.service.description

            case .FiatAsset, .NothingAsset, .OtherAsset:
                return "—"  // FIXME: Display something in these cases
            }
        }
    }

    var formattedValue: String {
        if case .FiatAsset(let fiatAsset) = gained {
            return fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode))
        } else if case .FiatAsset(let fiatAsset) = lost {
            return (-fiatAsset.amount).formatted(.currency(code: fiatAsset.currencyCode))
        } else {
            return "—"
        }
    }

    var logoURL: URL? {
        // FIXME: Log if URLs don't decode (or decode them earlier)
        switch gained {
        case .TransportAsset(let transportAsset):
            return URL(string: transportAsset.imageURL)
        case .MarketTradeAsset(let marketAsset):
            return URL(string: marketAsset.logoURL)

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch lost {
            case .TransportAsset(let transportAsset):
                return URL(string: transportAsset.imageURL)
            case .MarketTradeAsset(let marketAsset):
                return URL(string: marketAsset.logoURL)

            case .FiatAsset, .NothingAsset, .OtherAsset:
                return nil  // FIXME: Display something in these cases
            }
        }
    }

    var _context: Models.TradeQuoteContext {
        let linkedAccountID: String
        switch gained {
        case .TransportAsset(let transportAsset):
            linkedAccountID = transportAsset.linkedAccountID
        case .MarketTradeAsset(let marketAsset):
            linkedAccountID = marketAsset.linkedAccountID

        case .FiatAsset, .NothingAsset, .OtherAsset:
            switch lost {
            case .TransportAsset(let transportAsset):
                linkedAccountID = transportAsset.linkedAccountID
            case .MarketTradeAsset(let marketAsset):
                linkedAccountID = marketAsset.linkedAccountID

            case .FiatAsset, .NothingAsset, .OtherAsset:
                linkedAccountID = "FIXME"  // FIXME: Do something in these cases
            }
        }

        return .init(linkedAccountID: linkedAccountID, context: context)
    }
}
