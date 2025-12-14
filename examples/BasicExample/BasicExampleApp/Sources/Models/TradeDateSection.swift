import Candle
import Foundation

struct TradeDateSection: Identifiable {
    let date: Date?
    let trades: [Candle.Models.Trade]

    var id: String { date?.ISO8601Format() ?? "nil" }

    var title: String {
        guard let date else { return "Unknown" }

        let calendar = Calendar.current

        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
