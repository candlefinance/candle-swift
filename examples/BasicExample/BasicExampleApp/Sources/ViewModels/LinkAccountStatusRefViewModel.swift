import Candle
import Foundation

struct LinkedAccountStatusRefViewModel {
    let linkedAccountStatusRef: Models.LinkedAccountStatusRef
}

extension LinkedAccountStatusRefViewModel: ItemViewModel {
    var title: String { linkedAccountStatusRef.service.name }
    var subtitle: String { linkedAccountStatusRef.serviceUserID }
    var logoURL: URL? { linkedAccountStatusRef.service.logoURL }

    var value: String {
        switch linkedAccountStatusRef.state {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .unavailable: return "Unavailable"
        }
    }

    var details: [Detail] { [] }
    mutating func reload() async throws(ItemReloadError) {}
}

extension LinkedAccountStatusRefViewModel: Identifiable {
    var id: String { linkedAccountStatusRef.linkedAccountID }
}
