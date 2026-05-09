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
        case .event(let eventAsset):
            text = eventAsset.assetKind.description
            color = .cyan
        case .messageThread(let messageThreadAsset):
            text = messageThreadAsset.assetKind.description
            color = .blue
        case .friendRequest(let friendRequestAsset):
            text = friendRequestAsset.assetKind.description
            color = .blue
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
