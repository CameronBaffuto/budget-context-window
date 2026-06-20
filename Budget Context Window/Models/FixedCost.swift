import Foundation
import SwiftData

@Model
final class FixedCost {
    var name: String
    var amountCents: Int
    var isEnabled: Bool
    var createdAt: Date

    init(name: String, amountCents: Int, isEnabled: Bool = true, createdAt: Date = .now) {
        self.name = name
        self.amountCents = amountCents
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
}
