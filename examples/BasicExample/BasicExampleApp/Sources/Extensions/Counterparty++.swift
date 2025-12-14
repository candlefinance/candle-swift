import Candle
import SwiftUI

extension Candle.Models.Counterparty {
    var badge: Badge {
        let text: String
        let color: Color
        switch self {
        case .MerchantCounterparty(let merchantCounterparty):
            text = merchantCounterparty.kind.description
            color = .cyan
        case .ServiceCounterparty(let serviceCounterparty):
            text = serviceCounterparty.kind.description
            color = .purple
        case .UserCounterparty(let userCounterparty):
            text = userCounterparty.kind.description
            color = .brown
        }

        return .init(id: "counterparty", text: text, color: color)
    }
}
