import Candle
import SwiftUI

extension Candle.Models.LinkedAccount {
    var title: String {
        if case .active(let activeDetails) = details {
            return activeDetails.legalName
        } else {
            return serviceUserID
        }
    }

    var badge: Badge {
        let text: String
        let color: Color

        switch details {
        case .active(let activeDetails):
            text = activeDetails.state.description
            color = .green
        case .inactive(let inactiveDetails):
            text = inactiveDetails.state.description
            color = .red
        case .unavailable(let unavailableDetails):
            text = unavailableDetails.state.description
            color = .yellow
        }

        return .init(id: "state", text: text, color: color)
    }
}
