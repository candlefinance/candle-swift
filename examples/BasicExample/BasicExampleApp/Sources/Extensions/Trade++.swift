import Candle
import Foundation

extension Models.Trade {
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

    var formattedTitle: String {
        switch counterparty {
        case .MerchantCounterparty(let merchantCounterparty): return merchantCounterparty.name
        case .UserCounterparty(let userCounterparty): return userCounterparty.legalName
        case .ServiceCounterparty(let serviceCounterparty):
            return serviceCounterparty.service.description
        }
    }

    var formattedSubtitle: String {
        let tradeDate = ISO8601DateFormatter.candle.date(from: dateTime)

        return tradeDate?.formatted(date: .complete, time: .complete) ?? dateTime
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

    var logoURL: URL {
        switch counterparty {
        // FIXME: Log if URLs don't decode (or decode them earlier)
        case .MerchantCounterparty(let merchantCounterparty):
            return URL(string: merchantCounterparty.logoURL)!
        case .UserCounterparty(let userCounterparty):
            return URL(string: userCounterparty.avatarURL)!
        case .ServiceCounterparty(let serviceCounterparty):
            return serviceCounterparty.service.logoURL
        }
    }
}
