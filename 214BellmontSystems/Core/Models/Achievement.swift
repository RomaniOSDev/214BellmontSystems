import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_weekly_plan",
            title: "First Weekly Plan",
            description: "Set your first weekly intention",
            icon: "calendar.badge.checkmark"
        ),
        AchievementDefinition(
            id: "energy_mapped",
            title: "Energy Mapped",
            description: "Completed your first Energy Day Map",
            icon: "bolt.circle.fill"
        ),
        AchievementDefinition(
            id: "one_outcome",
            title: "One Outcome Locked",
            description: "Set a primary daily outcome",
            icon: "target"
        ),
        AchievementDefinition(
            id: "peak_block",
            title: "Peak Block Completed",
            description: "Finished a Peak energy Flow Block",
            icon: "bolt.fill"
        ),
        AchievementDefinition(
            id: "momentum_50",
            title: "Momentum 50",
            description: "Reached a Momentum Score of 50",
            icon: "chart.line.uptrend.xyaxis"
        ),
        AchievementDefinition(
            id: "commitment_kept",
            title: "Commitment Kept",
            description: "Kept a Weekly Commitment",
            icon: "checkmark.seal.fill"
        ),
        AchievementDefinition(
            id: "momentum_80",
            title: "In the Flow",
            description: "Reached a Momentum Score of 80",
            icon: "flame.fill"
        ),
        AchievementDefinition(
            id: "flow_streak_7",
            title: "Flow Streak",
            description: "Maintained activity for 7 days",
            icon: "crown.fill"
        )
    ]

    func isUnlocked(store: AppDataStore) -> Bool {
        switch id {
        case "first_weekly_plan":
            return !store.weeklyPlan.intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case "energy_mapped":
            return store.energyDayMap != nil || store.energyMapsCompleted > 0
        case "one_outcome":
            return store.dayOutcome?.isSet == true || store.outcomesLocked > 0
        case "peak_block":
            return store.peakBlocksCompleted >= 1
        case "momentum_50":
            return store.momentumBreakdown.total >= 50 || store.highestMomentum >= 50
        case "commitment_kept":
            return store.commitmentStatus == .kept || store.commitmentsKept >= 1
        case "momentum_80":
            return store.momentumBreakdown.total >= 80 || store.highestMomentum >= 80
        case "flow_streak_7":
            return store.streakDays >= 7 || store.longestStreak >= 7
        default:
            return false
        }
    }
}
