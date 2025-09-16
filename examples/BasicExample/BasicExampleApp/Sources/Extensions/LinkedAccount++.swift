import Candle

extension Candle.Models.LinkedAccount {
    var formattedSubtitle: String {
        switch details {
        case .ActiveLinkedAccountDetails(let activeDetails): return activeDetails.legalName
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            switch inactiveDetails.state {
            case .inactive: return "Inactive"
            case .unavailable: return "Unavailable"
            }
        }
    }
}
