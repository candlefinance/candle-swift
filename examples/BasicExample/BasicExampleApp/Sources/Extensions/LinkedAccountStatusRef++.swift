import Candle
import SwiftUI

extension Candle.Models.LinkedAccountStatusRef {
    var badge: Badge {
        let color: Color

        switch state {
        case .active: color = .green
        case .inactive: color = .red
        case .unavailable: color = .yellow
        }

        return .init(id: "state", text: state.description, color: color)
    }
}
