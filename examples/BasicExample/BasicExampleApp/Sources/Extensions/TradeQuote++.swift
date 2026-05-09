import Candle
import Foundation

extension Candle.Models.TradeQuote {
    // FIXME: Support market -> market trades, etc
    var title: String {
        switch gained {
        case .crypto(let cryptoAsset): return cryptoAsset.name
        case .stock(let stockAsset): return stockAsset.name
        case .transport(let transportAsset): return transportAsset.name
        case .event(let eventAsset): return eventAsset.name
        case .friendRequest(let friendRequestAsset): return friendRequestAsset.user.legalName
        default:
            switch lost {
            case .crypto(let cryptoAsset): return cryptoAsset.name
            case .stock(let stockAsset): return stockAsset.name
            case .transport(let transportAsset): return transportAsset.name
            case .event(let eventAsset): return eventAsset.name
            case .friendRequest(let friendRequestAsset): return friendRequestAsset.user.legalName
            default:
                switch counterparty {
                case .user(let userCounterparty): return userCounterparty.legalName
                case .merchant(let merchantCounterparty): return merchantCounterparty.name
                case .service(let serviceCounterparty):
                    return serviceCounterparty.service.displayName
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
        case .crypto(let cryptoAsset): return cryptoAsset.service.logoURLValue
        case .stock(let stockAsset): return stockAsset.service.logoURLValue
        case .transport(let transportAsset): return transportAsset.service.logoURLValue
        case .event(let eventAsset): return eventAsset.service.logoURLValue
        case .messageThread(let messageThreadAsset): return messageThreadAsset.service.logoURLValue
        case .friendRequest(let friendRequestAsset): return friendRequestAsset.service.logoURLValue
        case .fiat(let fiatAsset): return fiatAsset.service.logoURLValue
        default:
            switch lost {
            case .crypto(let cryptoAsset): return cryptoAsset.service.logoURLValue
            case .stock(let stockAsset): return stockAsset.service.logoURLValue
            case .transport(let transportAsset): return transportAsset.service.logoURLValue
            case .event(let eventAsset): return eventAsset.service.logoURLValue
            case .messageThread(let messageThreadAsset):
                return messageThreadAsset.service.logoURLValue
            case .friendRequest(let friendRequestAsset):
                return friendRequestAsset.service.logoURLValue
            case .fiat(let fiatAsset): return fiatAsset.service.logoURLValue
            default:
                if case .service(let serviceCounterparty) = counterparty {
                    return serviceCounterparty.service.logoURLValue
                }
                // FIXME: Always expose a service in Trade model
                return nil
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
        case .event(let eventAsset): linkedAccountID = eventAsset.linkedAccountID
        case .crypto(let cryptoAsset): linkedAccountID = cryptoAsset.linkedAccountID
        case .stock(let stockAsset): linkedAccountID = stockAsset.linkedAccountID
        case .messageThread(let messageThreadAsset):
            linkedAccountID = messageThreadAsset.linkedAccountID
        case .friendRequest(let friendRequestAsset):
            linkedAccountID = friendRequestAsset.linkedAccountID

        case .fiat, .nothing, .other:
            switch lost {
            case .transport(let transportAsset): linkedAccountID = transportAsset.linkedAccountID
            case .event(let eventAsset): linkedAccountID = eventAsset.linkedAccountID
            case .crypto(let cryptoAsset): linkedAccountID = cryptoAsset.linkedAccountID
            case .stock(let stockAsset): linkedAccountID = stockAsset.linkedAccountID
            case .messageThread(let messageThreadAsset):
                linkedAccountID = messageThreadAsset.linkedAccountID
            case .friendRequest(let friendRequestAsset):
                linkedAccountID = friendRequestAsset.linkedAccountID
            // FIXME: Do something in these cases
            case .fiat, .nothing, .other: linkedAccountID = "FIXME"
            }
        }

        return .init(linkedAccountID: linkedAccountID, context: context)
    }
}
