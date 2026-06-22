import Foundation

struct AppleCardTransaction: Identifiable, Hashable {
    static let importSource = "apple-card-csv"

    let transactionDate: Date
    let merchant: String
    let category: String
    let type: String
    let amountCents: Int

    var id: String {
        importIdentifier
    }

    var isExpensePurchase: Bool {
        amountCents > 0 && (type.isEmpty || type.localizedCaseInsensitiveCompare("Purchase") == .orderedSame)
    }

    var importIdentifier: String {
        let dateText = Self.identifierDateFormatter.string(from: transactionDate)
        return [
            Self.importSource,
            dateText,
            merchant.normalizedImportComponent,
            category.normalizedImportComponent,
            type.normalizedImportComponent,
            String(amountCents)
        ].joined(separator: "|")
    }

    private static let identifierDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private extension String {
    var normalizedImportComponent: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
    }
}
