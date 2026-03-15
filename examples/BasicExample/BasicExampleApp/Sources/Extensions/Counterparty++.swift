import Candle
import SwiftUI

extension Candle.Models.Counterparty {
    var badge: Badge {
        let text: String
        let color: Color
        switch self {
        case .merchant(let merchantCounterparty):
            text = merchantCounterparty.kind.description
            color = .cyan
        case .service(let serviceCounterparty):
            text = serviceCounterparty.kind.description
            color = .purple
        case .user(let userCounterparty):
            text = userCounterparty.kind.description
            color = .brown
        }

        return .init(id: "counterparty", text: text, color: color)
    }
}
