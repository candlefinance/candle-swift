import Candle
import SwiftUI

extension Candle.Models.TradeAsset {
    var badge: Badge {
        let text: String
        let color: Color
        switch self {
        case .fiat(let fiatAsset):
            text = fiatAsset.assetKind.description
            color = .assetKindFiat
        case .crypto(let cryptoAsset):
            text = cryptoAsset.assetKind.description
            color = .assetKindCrypto
        case .stock(let stockAsset):
            text = stockAsset.assetKind.description
            color = .assetKindStock
        case .transport(let transportAsset):
            text = transportAsset.assetKind.description
            color = .assetKindTransport
        case .other(let otherAsset):
            text = otherAsset.assetKind.description
            color = .gray
        case .nothing(let nothingAsset):
            text = nothingAsset.assetKind.description
            color = .assetKindNothing
        }

        return .init(id: "assetKind", text: text, color: color)
    }
}
