import Foundation
import SwiftData

@Model
final class Expense {
    var name: String
    var amountCents: Int
    var date: Date
    var createdAt: Date

    init(name: String, amountCents: Int, date: Date = .now, createdAt: Date = .now) {
        self.name = name
        self.amountCents = amountCents
        self.date = date
        self.createdAt = createdAt
    }
}
