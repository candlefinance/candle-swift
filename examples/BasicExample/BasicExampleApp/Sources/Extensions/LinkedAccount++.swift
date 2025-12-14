import Candle
import SwiftUI

extension Candle.Models.LinkedAccount {
    var title: String {
        if case .ActiveLinkedAccountDetails(let activeDetails) = details {
            return activeDetails.legalName
        } else {
            return serviceUserID
        }
    }

    var badge: Badge {
        let text: String
        let color: Color

        switch details {
        case .ActiveLinkedAccountDetails(let activeDetails):
            text = activeDetails.state.description
            color = .green
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            text = inactiveDetails.state.description
            switch inactiveDetails.state {
            case .inactive: color = .red
            case .unavailable: color = .yellow
            }
        }

        return .init(id: "state", text: text, color: color)
    }
}
