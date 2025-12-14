import Candle
import SFSafeSymbols

enum QuoteTemplate: String, CaseIterable, Identifiable, CustomStringConvertible {
    case fiatTransport
    case fiatOtherUser
    // FIXME: Add back when we support requesting money
    //    case otherFiatUser
    case fiatCrypto
    case cryptoFiat
    // FIXME: Add back when we support stock trading
    //    case fiatStock
    //    case stockFiat

    var id: String { rawValue }

    var lostAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest {
        switch self {
        //        case .otherFiatUser: return .OtherAssetQuoteRequest(.init(assetKind: .other))
        case .fiatTransport, .fiatCrypto, .fiatOtherUser:  //, .fiatStock:
            return .FiatAssetQuoteRequest(.init(assetKind: .fiat))
        case .cryptoFiat: return .MarketAssetQuoteRequest(.init(assetKind: .crypto))
        //        case .stockFiat: return .MarketAssetQuoteRequest(.init(assetKind: .stock))
        }
    }

    var gainedAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest {
        switch self {
        case .fiatOtherUser: return .OtherAssetQuoteRequest(.init(assetKind: .other))
        case .fiatTransport: return .TransportAssetQuoteRequest(.init(assetKind: .transport))
        case .fiatCrypto: return .MarketAssetQuoteRequest(.init(assetKind: .crypto))
        //        case .fiatStock: return .MarketAssetQuoteRequest(.init(assetKind: .stock))
        case .cryptoFiat:  //, .stockFiat, .otherFiatUser:
            return .FiatAssetQuoteRequest(.init(assetKind: .fiat))
        }
    }

    var counterpartyQuoteRequest: Candle.Models.CounterpartyQuoteRequest? {
        switch self {
        case .fiatOtherUser:  //, .otherFiatUser:
            return .UserCounterpartyQuoteRequest(.init(kind: .user))
        case .fiatTransport, .fiatCrypto, .cryptoFiat:  //, .fiatStock, .stockFiat:
            return nil
        }
    }

    var symbol: SFSymbol {
        switch self {
        case .fiatOtherUser: return .paperplane
        //        case .otherFiatUser: return .handRaised
        case .fiatTransport: return .car
        case .fiatCrypto:  //, .fiatStock:
            return .chartLineUptrendXyaxis
        case .cryptoFiat:  //, .stockFiat:
            return .chartLineDowntrendXyaxis
        }
    }

    var description: String {
        switch self {
        case .fiatOtherUser: return "Send Money"
        //        case .otherFiatUser: return "Request Money"
        case .fiatTransport: return "Book Ride"
        case .fiatCrypto: return "Buy Crypto"
        //        case .fiatStock: return "Buy Stock"
        case .cryptoFiat: return "Sell Crypto"
        //        case .stockFiat: return "Sell Stock"
        }
    }
}
