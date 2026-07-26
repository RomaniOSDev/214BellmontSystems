import Foundation

struct WeeklyPlan: Codable, Equatable {
    var weekStart: Date
    var intention: String
    var priorityOutcomes: [String]
    var plannedFocusMinutes: Int
    /// Locked weekly commitment — focus minutes target.
    var committedFocusMinutes: Int?
    /// Locked when user taps Commit for the week.
    var commitmentLocked: Bool
    var commitmentLockedAt: Date?

    init(
        weekStart: Date = WeeklyPlan.currentWeekStart(),
        intention: String = "",
        priorityOutcomes: [String] = [],
        plannedFocusMinutes: Int = 300,
        committedFocusMinutes: Int? = nil,
        commitmentLocked: Bool = false,
        commitmentLockedAt: Date? = nil
    ) {
        self.weekStart = Calendar.current.startOfDay(for: weekStart)
        self.intention = intention
        self.priorityOutcomes = priorityOutcomes
        self.plannedFocusMinutes = plannedFocusMinutes
        self.committedFocusMinutes = committedFocusMinutes
        self.commitmentLocked = commitmentLocked
        self.commitmentLockedAt = commitmentLockedAt
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

    var hasValidCommitment: Bool {
        commitmentLocked
            && !(intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            && priorityOutcomes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 1
            && (committedFocusMinutes ?? plannedFocusMinutes) > 0
    }

    enum CodingKeys: String, CodingKey {
        case weekStart, intention, priorityOutcomes, plannedFocusMinutes
        case committedFocusMinutes, commitmentLocked, commitmentLockedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weekStart = try container.decode(Date.self, forKey: .weekStart)
        intention = try container.decode(String.self, forKey: .intention)
        priorityOutcomes = try container.decode([String].self, forKey: .priorityOutcomes)
        plannedFocusMinutes = try container.decode(Int.self, forKey: .plannedFocusMinutes)
        committedFocusMinutes = try container.decodeIfPresent(Int.self, forKey: .committedFocusMinutes)
        commitmentLocked = try container.decodeIfPresent(Bool.self, forKey: .commitmentLocked) ?? false
        commitmentLockedAt = try container.decodeIfPresent(Date.self, forKey: .commitmentLockedAt)
    }
}
