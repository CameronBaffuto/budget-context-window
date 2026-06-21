import Foundation

struct BudgetPeriod: Equatable, Hashable {
    let monthKey: String
    let interval: DateInterval
    let label: String

    static func current(calendar: Calendar = .current, date: Date = .now) -> BudgetPeriod {
        BudgetPeriod(calendar: calendar, date: date)
    }

    init(calendar: Calendar = .current, date: Date) {
        let interval = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0)
        self.interval = interval
        self.label = interval.start.formatted(.dateTime.month(.wide).year())
        self.monthKey = BudgetPeriod.monthKey(for: interval.start, calendar: calendar)
    }

    func contains(_ date: Date) -> Bool {
        date >= interval.start && date < interval.end
    }

    static func monthKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        return String(format: "%04d-%02d", year, month)
    }
}
