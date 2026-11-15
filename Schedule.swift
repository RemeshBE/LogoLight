import Foundation

struct DailyPlan {
    let on: Int
    let off: Int
    var allOff = false

    func isOn(at minute: Int) -> Bool {
        guard !allOff, on != off else { return false }
        if on < off { return (on..<off).contains(minute) }
        return minute >= on || minute < off
    }

    var litRanges: [Range<Int>] {
        guard !allOff, on != off else { return [] }
        return on < off ? [on..<off] : [0..<off, on..<1440]
    }
}

struct WeeklyPlan {
    let weekday: DailyPlan
    let weekend: DailyPlan?
    var calendar = Calendar.autoupdatingCurrent
    var sunsetByDay: [Date: Int] = [:]

    func plan(at date: Date) -> DailyPlan {
        let day = calendar.component(.weekday, from: date)
        let fixed = (day == 1 || day == 7) ? weekend ?? weekday : weekday
        guard let sunset = sunsetByDay[calendar.startOfDay(for: date)] else { return fixed }
        return DailyPlan(on: sunset, off: fixed.off, allOff: fixed.allOff)
    }

    func isOn(at date: Date) -> Bool {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return plan(at: date).isOn(at: (parts.hour ?? 0) * 60 + (parts.minute ?? 0))
    }

    func nextChange(after date: Date) -> Date? {
        guard let minute = calendar.dateInterval(of: .minute, for: date) else { return nil }
        let current = isOn(at: date)
        var candidate = minute.end
        // Check actual minutes so repeated and skipped local times follow the clock face.
        for _ in 0..<(8 * 1440) {
            if isOn(at: candidate) != current { return candidate }
            candidate += 60
        }
        return nil
    }
}
