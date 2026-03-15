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
        case .fiat, .transport, .other, .nothing: lostAssetNames = []
        }

        let gainedAssetNames: [String]
        switch gained {
        // FIXME: Add name
        case .crypto(let cryptoAsset): gainedAssetNames = [cryptoAsset.symbol]
        case .stock(let stockAsset): gainedAssetNames = [stockAsset.symbol]
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
}
