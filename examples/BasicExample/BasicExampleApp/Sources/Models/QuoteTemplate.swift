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
        //        case .otherFiatUser: return .other(.init())
        case .fiatTransport, .fiatCrypto, .fiatOtherUser:  //, .fiatStock:
            return .fiat(.init())
        case .cryptoFiat: return .crypto(.init())
        //        case .stockFiat: return .stock(.init())
        }
    }

    var gainedAssetQuoteRequest: Candle.Models.TradeAssetQuoteRequest {
        switch self {
        case .fiatOtherUser: return .other(.init())
        case .fiatTransport: return .transport(.init())
        case .fiatCrypto: return .crypto(.init())
        //        case .fiatStock: return .stock(.init())
        case .cryptoFiat:  //, .stockFiat, .otherFiatUser:
            return .fiat(.init())
        }
    }

    var counterpartyQuoteRequest: Candle.Models.CounterpartyQuoteRequest? {
        switch self {
        case .fiatOtherUser:  //, .otherFiatUser:
            return .user(.init())
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
