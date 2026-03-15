import Candle
import SwiftUI

extension Candle.Models.TradeAssetQuoteRequest {
    var badge: Badge {
        let text: String
        let color: Color

        switch self {
        case .fiat(let fiatAssetQuoteRequest):
            text = fiatAssetQuoteRequest.assetKind.description
            color = .assetKindFiat
        case .crypto(let cryptoAssetQuoteRequest):
            text = cryptoAssetQuoteRequest.assetKind.description
            color = .assetKindCrypto
        case .stock(let stockAssetQuoteRequest):
            text = stockAssetQuoteRequest.assetKind.description
            color = .assetKindStock
        case .transport(let transportAssetQuoteRequest):
            text = transportAssetQuoteRequest.assetKind.description
            color = .assetKindTransport
        case .other(let otherAssetQuoteRequest):
            text = otherAssetQuoteRequest.assetKind.description
            color = .gray
        case .nothing(let nothingAssetQuoteRequest):
            text = nothingAssetQuoteRequest.assetKind.description
            color = .assetKindNothing
        }
        return .init(id: "assetKind", text: text, color: color)
    }
}
