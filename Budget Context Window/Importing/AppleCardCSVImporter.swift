import Foundation

@MainActor
enum AppleCardCSVImporter {
    enum ImportError: LocalizedError {
        case unreadableData
        case missingColumns([String])
        case invalidRows

        var errorDescription: String? {
            switch self {
            case .unreadableData:
                "The selected file could not be read as text."
            case .missingColumns(let columns):
                "The CSV is missing: \(columns.joined(separator: ", "))."
            case .invalidRows:
                "No valid Apple Card transactions were found."
            }
        }
    }

    static func transactions(from data: Data) throws -> [AppleCardTransaction] {
        guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw ImportError.unreadableData
        }

        return try transactions(fromCSVText: text)
    }

    static func transactions(fromCSVText text: String) throws -> [AppleCardTransaction] {
        let rows = CSVParser.rows(from: text)
        guard let header = rows.first else {
            throw ImportError.invalidRows
        }

        let headerLookup = Dictionary(uniqueKeysWithValues: header.enumerated().map { index, name in
            (name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), index)
        })

        let requiredColumns = [
            "transaction date",
            "merchant",
            "category",
            "type",
            "amount (usd)"
        ]
        let missingColumns = requiredColumns.filter { headerLookup[$0] == nil }
        guard missingColumns.isEmpty else {
            throw ImportError.missingColumns(missingColumns)
        }

        let transactions = rows.dropFirst().compactMap { row -> AppleCardTransaction? in
            guard let transactionDate = value("transaction date", in: row, lookup: headerLookup).flatMap(Self.date(from:)),
                  let amountCents = value("amount (usd)", in: row, lookup: headerLookup).flatMap(CurrencyFormatter.cents(from:)) else {
                return nil
            }

            let merchant = value("merchant", in: row, lookup: headerLookup)?.trimmedForImport ?? ""
            guard !merchant.isEmpty else {
                return nil
            }

            return AppleCardTransaction(
                transactionDate: transactionDate,
                merchant: merchant,
                category: value("category", in: row, lookup: headerLookup)?.trimmedForImport ?? "",
                type: value("type", in: row, lookup: headerLookup)?.trimmedForImport ?? "",
                amountCents: amountCents
            )
        }

        guard !transactions.isEmpty else {
            throw ImportError.invalidRows
        }

        return transactions
    }

    private static func value(_ key: String, in row: [String], lookup: [String: Int]) -> String? {
        guard let index = lookup[key], row.indices.contains(index) else {
            return nil
        }

        return row[index]
    }

    private static func date(from input: String) -> Date? {
        dateFormatter.date(from: input.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
}

private enum CSVParser {
    static func rows(from text: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var isInsideQuotes = false
        var index = text.startIndex

        while index < text.endIndex {
            let character = text[index]

            if character == "\"" {
                let nextIndex = text.index(after: index)
                if isInsideQuotes, nextIndex < text.endIndex, text[nextIndex] == "\"" {
                    field.append("\"")
                    index = nextIndex
                } else {
                    isInsideQuotes.toggle()
                }
            } else if character == ",", !isInsideQuotes {
                row.append(field)
                field = ""
            } else if character == "\n", !isInsideQuotes {
                row.append(field)
                rows.append(row)
                row = []
                field = ""
            } else if character != "\r" {
                field.append(character)
            }

            index = text.index(after: index)
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }

        return rows.filter { row in
            row.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
    }
}

private extension String {
    var trimmedForImport: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
