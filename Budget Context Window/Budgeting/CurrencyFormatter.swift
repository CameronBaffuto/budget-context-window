import Foundation

enum CurrencyFormatter {
    static let dollars: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")

    static func dollarsText(for cents: Int) -> String {
        (Double(cents) / 100.0)
            .formatted(dollars.precision(.fractionLength(0 ... 2)))
    }

    static func decimalText(for cents: Int) -> String {
        let value = Double(cents) / 100.0
        return value.formatted(.number.precision(.fractionLength(0 ... 2)))
    }

    static func cents(from input: String) -> Int? {
        let filtered = input.filter { $0.isNumber || $0 == "." }
        guard let value = Decimal(string: filtered), value >= 0 else {
            return nil
        }

        let cents = value * 100
        return NSDecimalNumber(decimal: cents).rounding(accordingToBehavior: nil).intValue
    }
}
