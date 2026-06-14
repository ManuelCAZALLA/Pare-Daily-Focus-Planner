// RecurrenceEngine.swift
import Foundation

struct RecurrenceEngine {

    /// Genera las próximas N fechas para una recurrencia dada
    static func nextDates(from start: Date, recurrence: Recurrence, count: Int = 7) -> [Date] {
        var dates: [Date] = []
        var current = start

        for _ in 0..<count {
            switch recurrence {
            case .daily:
                current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
            case .weekly(let days):
                current = nextWeekday(from: current, allowedDays: days)
            case .monthly(let day):
                current = nextMonthDate(from: current, day: day)
            case .custom(let interval):
                current = Calendar.current.date(byAdding: .day, value: interval, to: current)!
            }
            dates.append(current)
        }
        return dates
    }

    private static func nextWeekday(from date: Date, allowedDays: [Int]) -> Date {
        var next = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        for _ in 0..<7 {
            let wd = Calendar.current.component(.weekday, from: next)
            let mapped = wd == 1 ? 7 : wd - 1  // ISO: lunes=1
            if allowedDays.contains(mapped) { return next }
            next = Calendar.current.date(byAdding: .day, value: 1, to: next)!
        }
        return next
    }

    private static func nextMonthDate(from date: Date, day: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month], from: date)
        comps.month! += 1
        comps.day = day
        return Calendar.current.date(from: comps) ?? date
    }
}
