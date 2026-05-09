import Candle
import Foundation
import SwiftUI

extension Candle.Models.Trade {
    var searchTokens: [String] {
        let counterpartyNames: [String]
        switch counterparty {
        case .merchant(let merchantCounterparty): counterpartyNames = [merchantCounterparty.name]
        case .service: counterpartyNames = []
        case .user(let userCounterparty):
            counterpartyNames = [userCounterparty.username, userCounterparty.legalName]
        }

        let lostAssetNames: [String]
        switch lost {
        // FIXME: Add name
        case .crypto(let cryptoAsset): lostAssetNames = [cryptoAsset.symbol]
        case .stock(let stockAsset): lostAssetNames = [stockAsset.symbol]
        case .event(let eventAsset): lostAssetNames = [eventAsset.name]
        case .messageThread(let messageThreadAsset):
            lostAssetNames = messageThreadAsset.messages.map(\.text)
        case .friendRequest(let friendRequestAsset):
            lostAssetNames = [
                friendRequestAsset.user.legalName, friendRequestAsset.user.username,
                friendRequestAsset.direction.rawValue,
            ]
        case .fiat, .transport, .other, .nothing: lostAssetNames = []
        }

        let gainedAssetNames: [String]
        switch gained {
        // FIXME: Add name
        case .crypto(let cryptoAsset): gainedAssetNames = [cryptoAsset.symbol]
        case .stock(let stockAsset): gainedAssetNames = [stockAsset.symbol]
        case .event(let eventAsset): gainedAssetNames = [eventAsset.name]
        case .messageThread(let messageThreadAsset):
            gainedAssetNames = messageThreadAsset.messages.map(\.text)
        case .friendRequest(let friendRequestAsset):
            gainedAssetNames = [
                friendRequestAsset.user.legalName, friendRequestAsset.user.username,
                friendRequestAsset.direction.rawValue,
            ]
        case .fiat, .transport, .other, .nothing: gainedAssetNames = []
        }

        return counterpartyNames + lostAssetNames + gainedAssetNames
    }

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
}
