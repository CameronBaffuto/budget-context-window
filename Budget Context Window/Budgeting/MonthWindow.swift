import Foundation

struct MonthWindow {
    let interval: DateInterval
    let label: String

    static func current(calendar: Calendar = .current, date: Date = .now) -> MonthWindow {
        let interval = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0)
        let label = interval.start.formatted(.dateTime.month(.wide).year())
        return MonthWindow(interval: interval, label: label)
    }

    func contains(_ date: Date) -> Bool {
        date >= interval.start && date < interval.end
    }
}
