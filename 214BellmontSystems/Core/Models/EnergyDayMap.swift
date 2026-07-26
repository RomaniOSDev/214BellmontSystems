import Foundation

/// Morning energy profile that drives auto-generated Flow Blocks for the day.
struct EnergyDayMap: Codable, Equatable {
    var day: Date
    var dayEnergy: EnergyLevel
    var generatedAt: Date

    init(
        day: Date = Date(),
        dayEnergy: EnergyLevel,
        generatedAt: Date = Date()
    ) {
        self.day = Calendar.current.startOfDay(for: day)
        self.dayEnergy = dayEnergy
        self.generatedAt = generatedAt
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(day)
    }

    /// Suggested block templates based on morning energy.
    func suggestedBlocks(for day: Date = Date()) -> [FlowBlock] {
        switch dayEnergy {
        case .peak:
            return [
                FlowBlock(title: "Peak deep work", startHour: 9, startMinute: 0, durationMinutes: 90, energyLevel: .peak, scheduledDay: day),
                FlowBlock(title: "Steady delivery", startHour: 11, startMinute: 0, durationMinutes: 45, energyLevel: .steady, scheduledDay: day),
                FlowBlock(title: "Low recovery / admin", startHour: 15, startMinute: 0, durationMinutes: 30, energyLevel: .low, scheduledDay: day)
            ]
        case .steady:
            return [
                FlowBlock(title: "Steady planning", startHour: 9, startMinute: 0, durationMinutes: 30, energyLevel: .steady, scheduledDay: day),
                FlowBlock(title: "Steady build block", startHour: 10, startMinute: 0, durationMinutes: 60, energyLevel: .steady, scheduledDay: day),
                FlowBlock(title: "Low wrap-up", startHour: 16, startMinute: 0, durationMinutes: 25, energyLevel: .low, scheduledDay: day)
            ]
        case .low:
            return [
                FlowBlock(title: "Low inbox & admin", startHour: 9, startMinute: 30, durationMinutes: 40, energyLevel: .low, scheduledDay: day),
                FlowBlock(title: "Steady light progress", startHour: 11, startMinute: 0, durationMinutes: 35, energyLevel: .steady, scheduledDay: day),
                FlowBlock(title: "Low review & reset", startHour: 15, startMinute: 30, durationMinutes: 30, energyLevel: .low, scheduledDay: day)
            ]
        }
    }

    /// Peak tasks cannot live in Low slots. Steady is allowed anywhere.
    static func allows(taskEnergy: EnergyLevel, in slot: EnergyLevel) -> Bool {
        if taskEnergy == .peak && slot == .low { return false }
        if taskEnergy == .low && slot == .peak { return false }
        return true
    }
}

struct DayOutcome: Codable, Equatable {
    var day: Date
    var primaryOutcome: String
    var isCompleted: Bool

    init(day: Date = Date(), primaryOutcome: String = "", isCompleted: Bool = false) {
        self.day = Calendar.current.startOfDay(for: day)
        self.primaryOutcome = primaryOutcome
        self.isCompleted = isCompleted
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(day)
    }

    var isSet: Bool {
        !primaryOutcome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

enum CommitmentStatus: String {
    case notCommitted
    case kept
    case missed
    case inProgress

    var displayName: String {
        switch self {
        case .notCommitted: return "Not Committed"
        case .kept: return "Commitment Kept"
        case .missed: return "Commitment Missed"
        case .inProgress: return "In Progress"
        }
    }

    var icon: String {
        switch self {
        case .notCommitted: return "circle.dashed"
        case .kept: return "checkmark.seal.fill"
        case .missed: return "xmark.seal.fill"
        case .inProgress: return "hourglass"
        }
    }
}
