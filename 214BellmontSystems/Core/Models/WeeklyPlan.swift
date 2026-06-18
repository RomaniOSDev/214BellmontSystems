import Foundation

struct WeeklyPlan: Codable, Equatable {
    var weekStart: Date
    var intention: String
    var priorityOutcomes: [String]
    var plannedFocusMinutes: Int

    init(
        weekStart: Date = WeeklyPlan.currentWeekStart(),
        intention: String = "",
        priorityOutcomes: [String] = [],
        plannedFocusMinutes: Int = 300
    ) {
        self.weekStart = Calendar.current.startOfDay(for: weekStart)
        self.intention = intention
        self.priorityOutcomes = priorityOutcomes
        self.plannedFocusMinutes = plannedFocusMinutes
    }

    static func currentWeekStart(calendar: Calendar = .current) -> Date {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
    }

    var isCurrentWeek: Bool {
        Calendar.current.isDate(weekStart, inSameDayAs: WeeklyPlan.currentWeekStart())
    }
}
