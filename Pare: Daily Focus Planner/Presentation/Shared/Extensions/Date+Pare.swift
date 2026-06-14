// Date+Pare.swift
import Foundation

extension Date {
    var startOfWeek: Date {
        var cal  = Calendar(identifier: .iso8601)
        cal.locale = Locale.current
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }

    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }
    var isThisWeek: Bool { Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) }

    func formatted(style: DateFormatter.Style) -> String {
        let f = DateFormatter()
        f.dateStyle = style
        f.locale    = Locale.current
        return f.string(from: self)
    }
}
