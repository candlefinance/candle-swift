import Candle
import SwiftUI

extension Candle.Models.AssetAccount {
    var badge: Badge {
        let text: String
        let color: Color

        switch self {
        case .fiat(let fiatAccount):
            text = fiatAccount.assetKind.description
            color = .assetKindFiat
        case .crypto(let cryptoAccount):
            text = cryptoAccount.assetKind.description
            color = .assetKindCrypto
        case .stock(let stockAccount):
            text = stockAccount.assetKind.description
            color = .assetKindStock
        case .transport(let transportAccount):
            text = transportAccount.assetKind.description
            color = .assetKindTransport
        }

        return .init(id: "assetKind", text: text, color: color)
    }

    var value: String? {
        if case .fiat(let fiatAccount) = self {
            return fiatAccount.balance?.formatted(.currency(code: fiatAccount.currencyCode))
        } else {
            return nil
        }
    }
}
