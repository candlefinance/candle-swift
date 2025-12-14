import Candle
import SwiftUI

extension Candle.Models.TradeAssetQuoteRequest {
    var badge: Badge {
        let text: String
        let color: Color

        switch self {
        case .FiatAssetQuoteRequest(let fiatAssetQuoteRequest):
            text = fiatAssetQuoteRequest.assetKind.description
            color = .assetKindFiat
        case .MarketAssetQuoteRequest(let marketAssetQuoteRequest):
            text = marketAssetQuoteRequest.assetKind.description
            color =
                marketAssetQuoteRequest.assetKind == .crypto ? .assetKindCrypto : .assetKindStock
        case .TransportAssetQuoteRequest(let transportAssetQuoteRequest):
            text = transportAssetQuoteRequest.assetKind.description
            color = .assetKindTransport
        case .OtherAssetQuoteRequest(let otherAssetQuoteRequest):
            text = otherAssetQuoteRequest.assetKind.description
            color = .gray
        case .NothingAssetQuoteRequest(let nothingAssetQuoteRequest):
            text = nothingAssetQuoteRequest.assetKind.description
            color = .assetKindNothing
        }
        return .init(id: "assetKind", text: text, color: color)
    }
}
