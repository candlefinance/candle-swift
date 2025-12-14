import Candle
import SwiftUI

extension Candle.Models.TradeAsset {
    var badge: Badge {
        let text: String
        let color: Color
        switch self {
        case .FiatAsset(let fiatAsset):
            text = fiatAsset.assetKind.description
            color = .assetKindFiat
        case .MarketTradeAsset(let marketAsset):
            text = marketAsset.assetKind.description
            switch marketAsset.assetKind {
            case .crypto: color = .assetKindCrypto
            case .stock: color = .assetKindStock
            }
        case .TransportAsset(let transportAsset):
            text = transportAsset.assetKind.description
            color = .assetKindTransport
        case .OtherAsset(let otherAsset):
            text = otherAsset.assetKind.description
            color = .gray
        case .NothingAsset(let nothingAsset):
            text = nothingAsset.assetKind.description
            color = .assetKindNothing
        }

        return .init(id: "assetKind", text: text, color: color)
    }
}
