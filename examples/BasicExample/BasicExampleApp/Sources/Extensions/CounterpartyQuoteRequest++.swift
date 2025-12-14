import Candle
import SwiftUI

extension Candle.Models.CounterpartyQuoteRequest {
    var badge: Badge {
        let text: String
        let color: Color

        switch self {
        case .UserCounterpartyQuoteRequest(let userCounterpartyQuoteRequest):
            text = userCounterpartyQuoteRequest.kind.description
            color = .brown
        case .MerchantCounterpartyQuoteRequest(let merchantCounterpartyQuoteRequest):
            text = merchantCounterpartyQuoteRequest.kind.description
            color = .cyan
        case .ServiceCounterpartyQuoteRequest(let serviceCounterpartyQuoteRequest):
            text = serviceCounterpartyQuoteRequest.kind.description
            color = .purple
        }
        return .init(id: "kind", text: text, color: color)
    }
}
