import Candle
import Foundation

extension Candle.Models.TradeQuote {
    // FIXME: Support market -> market trades, etc
    var title: String {
        switch gained {
        case .crypto(let cryptoAsset): return cryptoAsset.name
        case .stock(let stockAsset): return stockAsset.name
        case .transport(let transportAsset): return transportAsset.name
        default:
            switch lost {
            case .crypto(let cryptoAsset): return cryptoAsset.name
            case .stock(let stockAsset): return stockAsset.name
            case .transport(let transportAsset): return transportAsset.name
            default:
                switch counterparty {
                case .user(let userCounterparty): return userCounterparty.legalName
                case .merchant(let merchantCounterparty): return merchantCounterparty.name
                case .service(let serviceCounterparty):
                    return serviceCounterparty.service.description
                }
            }
        }
    }

    // FIXME: Support market -> market trades, etc
    var value: String? {
        if case .fiat(let fiatAsset) = gained {
            return fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode))
        } else if case .fiat(let fiatAsset) = lost {
            return (-fiatAsset.amount).formatted(.currency(code: fiatAsset.currencyCode))
        } else {
            return nil
        }
    }

    // FIXME: Support market -> market trades, etc
    var logoURL: URL? {
        switch gained {
        case .crypto(let cryptoAsset): return cryptoAsset.service.logoURL
        case .stock(let stockAsset): return stockAsset.service.logoURL
        case .transport(let transportAsset): return transportAsset.service.logoURL
        case .fiat(let fiatAsset): return fiatAsset.service.logoURL
        default:
            switch lost {
            case .crypto(let cryptoAsset): return cryptoAsset.service.logoURL
            case .stock(let stockAsset): return stockAsset.service.logoURL
            case .transport(let transportAsset): return transportAsset.service.logoURL
            case .fiat(let fiatAsset): return fiatAsset.service.logoURL
            default:
                switch counterparty {
                case .service(let serviceCounterparty): return serviceCounterparty.service.logoURL
                // FIXME: Always expose a service in Trade model
                default: return nil
                }
            }
        }
    }

    var badges: [Badge] {
        [
            .init(id: "lostAssetKind", text: lost.badge.text, color: lost.badge.color),
            .init(id: "gainedAssetKind", text: gained.badge.text, color: gained.badge.color),
        ]
    }

    var _context: Candle.Models.TradeQuoteContext {
        let linkedAccountID: String
        switch gained {
        case .transport(let transportAsset): linkedAccountID = transportAsset.linkedAccountID
        case .crypto(let cryptoAsset): linkedAccountID = cryptoAsset.linkedAccountID
        case .stock(let stockAsset): linkedAccountID = stockAsset.linkedAccountID

        case .fiat, .nothing, .other:
            switch lost {
            case .transport(let transportAsset): linkedAccountID = transportAsset.linkedAccountID
            case .crypto(let cryptoAsset): linkedAccountID = cryptoAsset.linkedAccountID
            case .stock(let stockAsset): linkedAccountID = stockAsset.linkedAccountID
            // FIXME: Do something in these cases
            case .fiat, .nothing, .other: linkedAccountID = "FIXME"
            }
        }

        return .init(linkedAccountID: linkedAccountID, context: context)
    }
}
