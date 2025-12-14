import Candle
import Foundation
import SwiftUI

extension Candle.Models.Trade {
    var searchTokens: [String] {
        let counterpartyNames: [String]
        switch counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            counterpartyNames = [merchantCounterparty.name]
        case .ServiceCounterparty: counterpartyNames = []
        case .UserCounterparty(let userCounterparty):
            counterpartyNames = [userCounterparty.username, userCounterparty.legalName]
        }

        let lostAssetNames: [String]
        switch lost {
        // FIXME: Add name
        case .MarketTradeAsset(let marketTradeAsset): lostAssetNames = [marketTradeAsset.symbol]
        case .FiatAsset, .TransportAsset, .OtherAsset, .NothingAsset: lostAssetNames = []
        }

        let gainedAssetNames: [String]
        switch gained {
        // FIXME: Add name
        case .MarketTradeAsset(let marketTradeAsset): gainedAssetNames = [marketTradeAsset.symbol]
        case .FiatAsset, .TransportAsset, .OtherAsset, .NothingAsset: gainedAssetNames = []
        }

        return counterpartyNames + lostAssetNames + gainedAssetNames
    }

    // FIXME: Support market -> market trades, etc
    var title: String {
        switch gained {
        case .MarketTradeAsset(let marketAsset): return marketAsset.name
        case .TransportAsset(let transportAsset): return transportAsset.name
        default:
            switch lost {
            case .MarketTradeAsset(let marketAsset): return marketAsset.name
            case .TransportAsset(let transportAsset): return transportAsset.name
            default:
                switch counterparty {
                case .UserCounterparty(let userCounterparty): return userCounterparty.legalName
                case .MerchantCounterparty(let merchantCounterparty):
                    return merchantCounterparty.name
                case .ServiceCounterparty(let serviceCounterparty):
                    return serviceCounterparty.service.description
                }
            }
        }
    }

    // FIXME: Support market -> market trades, etc
    var value: String? {
        if case .FiatAsset(let fiatAsset) = gained {
            return fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode))
        } else if case .FiatAsset(let fiatAsset) = lost {
            return (-fiatAsset.amount).formatted(.currency(code: fiatAsset.currencyCode))
        } else {
            return nil
        }
    }

    // FIXME: Support market -> market trades, etc
    var logoURL: URL? {
        switch gained {
        case .MarketTradeAsset(let marketAsset): return marketAsset.service.logoURL
        case .TransportAsset(let transportAsset): return transportAsset.service.logoURL
        case .FiatAsset(let fiatAsset): return fiatAsset.service.logoURL
        default:
            switch lost {
            case .MarketTradeAsset(let marketAsset): return marketAsset.service.logoURL
            case .TransportAsset(let transportAsset): return transportAsset.service.logoURL
            case .FiatAsset(let fiatAsset): return fiatAsset.service.logoURL
            default:
                switch counterparty {
                case .ServiceCounterparty(let serviceCounterparty):
                    return serviceCounterparty.service.logoURL
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
