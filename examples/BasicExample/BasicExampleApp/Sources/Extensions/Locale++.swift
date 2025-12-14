import Foundation

extension Locale {
    func localizedSymbol(forCurrencyCode currencyCode: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        numberFormatter.locale = self
        return numberFormatter.currencySymbol
    }
}

extension Locale.Currency {
    static var activeCurrencies: [Self] {
        let codes = Set(
            Locale.availableIdentifiers.compactMap { id in Locale(identifier: id).currency }
        )
        return codes.sorted(using: KeyPathComparator(\.identifier))
    }
}
