import Candle
import SwiftUI

extension Candle.Models.TradeQuoteLinkedAccountResult {
    var linkedAccountID: Candle.Models.LinkedAccountID {
        switch self {
        case .resultsFound(let result): result.linkedAccountID
        case .noResults(let result): result.linkedAccountID
        case .sessionExpired(let result): result.linkedAccountID
        case .proxyUnavailable(let result): result.linkedAccountID
        case .unexpectedError(let result): result.linkedAccountID
        }
    }

    var service: Candle.Models.Service {
        switch self {
        case .resultsFound(let result): result.service
        case .noResults(let result): result.service
        case .sessionExpired(let result): result.service
        case .proxyUnavailable(let result): result.service
        case .unexpectedError(let result): result.service
        }
    }

    var serviceUserID: Candle.Models.ServiceUserID {
        switch self {
        case .resultsFound(let result): result.serviceUserID
        case .noResults(let result): result.serviceUserID
        case .sessionExpired(let result): result.serviceUserID
        case .proxyUnavailable(let result): result.serviceUserID
        case .unexpectedError(let result): result.serviceUserID
        }
    }

    var badges: [Badge] {
        switch self {
        case .resultsFound(let result):
            return [.init(id: "outcome", text: "results: \(result.count)", color: .green)]
        case .noResults(let result):
            return [.init(id: "outcome", text: result.reason.rawValue, color: .yellow)]
        case .sessionExpired: return [.init(id: "outcome", text: "session_expired", color: .red)]
        case .proxyUnavailable:
            return [.init(id: "outcome", text: "proxy_unavailable", color: .orange)]
        case .unexpectedError: return [.init(id: "outcome", text: "unexpected_error", color: .red)]
        }
    }
}
