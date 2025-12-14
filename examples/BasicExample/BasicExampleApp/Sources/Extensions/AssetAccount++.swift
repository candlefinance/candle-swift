import Candle
import SwiftUI

extension Candle.Models.AssetAccount {
    var badge: Badge {
        let text: String
        let color: Color

        switch self {
        case .FiatAccount(let fiatAccount):
            text = fiatAccount.assetKind.description
            color = .assetKindFiat
        case .MarketAccount(let marketAccount):
            text = marketAccount.assetKind.description
            switch marketAccount.assetKind {
            case .crypto: color = .assetKindCrypto
            case .stock: color = .assetKindStock
            }
        case .TransportAccount(let transportAccount):
            text = transportAccount.assetKind.description
            color = .assetKindTransport
        }

        return .init(id: "assetKind", text: text, color: color)
    }

    var value: String? {
        if case .FiatAccount(let fiatAccount) = self {
            return fiatAccount.balance?.formatted(.currency(code: fiatAccount.currencyCode))
        } else {
            return nil
        }
    }
}
