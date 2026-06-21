import Foundation

struct BudgetPeriod: Equatable, Hashable {
    let monthKey: String
    let interval: DateInterval
    let label: String

    static func current(calendar: Calendar = .current, date: Date = .now, startDay: Int = 1) -> BudgetPeriod {
        BudgetPeriod(calendar: calendar, date: date, startDay: startDay)
    }

    init(calendar: Calendar = .current, date: Date, startDay: Int = 1) {
        let startDay = max(1, min(startDay, 28))
        let monthInterval = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0)
        let currentMonthStart = monthInterval.start
        let day = calendar.component(.day, from: date)

        let cycleMonthStart = day >= startDay
            ? currentMonthStart
            : (calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? currentMonthStart)

        let cycleStart = calendar.date(bySetting: .day, value: startDay, of: cycleMonthStart) ?? cycleMonthStart
        let cycleEnd = calendar.date(byAdding: .month, value: 1, to: cycleStart) ?? cycleStart
        let interval = DateInterval(start: cycleStart, end: cycleEnd)

        self.interval = interval
        self.label = startDay == 1
            ? interval.start.formatted(.dateTime.month(.wide).year())
            : "\(interval.start.formatted(.dateTime.month(.abbreviated).day()))-\(cycleEnd.addingTimeInterval(-1).formatted(.dateTime.month(.abbreviated).day()))"
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
