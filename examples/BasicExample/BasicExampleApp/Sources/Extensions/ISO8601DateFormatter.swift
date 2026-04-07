import Foundation

extension ISO8601DateFormatter {
    static var candle: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

var defaultEventQuoteRequestDate: Date {
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) ?? .now
    return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) ?? tomorrow
}

var defaultEventQuoteRequestDateTime: String {
    ISO8601DateFormatter.candle.string(from: defaultEventQuoteRequestDate)
}
