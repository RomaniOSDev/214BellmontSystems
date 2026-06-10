import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "task_initiator",
            title: "Task Initiator",
            description: "Completed your first task",
            icon: "checkmark.circle.fill"
        ),
        AchievementDefinition(
            id: "focus_enthusiast",
            title: "Focus Enthusiast",
            description: "Completed 10 focus sessions",
            icon: "timer"
        ),
        AchievementDefinition(
            id: "habit_builder",
            title: "Habit Builder",
            description: "Logged your first habit check-in",
            icon: "leaf.fill"
        ),
        AchievementDefinition(
            id: "consistent_performer",
            title: "Consistent Performer",
            description: "Maintained a streak of tracking habits for a week",
            icon: "flame.fill"
        ),
        AchievementDefinition(
            id: "focused_hour",
            title: "Focused Hour",
            description: "Achieved total focus minutes of an hour",
            icon: "clock.fill"
        ),
        AchievementDefinition(
            id: "task_master",
            title: "Task Master",
            description: "Accomplished completion of ten tasks",
            icon: "star.fill"
        ),
        AchievementDefinition(
            id: "diligent_worker",
            title: "Diligent Worker",
            description: "Successfully completed fifty focus sessions",
            icon: "bolt.fill"
        ),
        AchievementDefinition(
            id: "habit_pro",
            title: "Habit Pro",
            description: "Reached fifty habit check-ins",
            icon: "crown.fill"
        )
    ]

    func isUnlocked(store: AppDataStore) -> Bool {
        switch id {
        case "task_initiator":
            return store.tasksCompleted >= 1
        case "focus_enthusiast":
            return store.focusSessionsCompleted >= 10
        case "habit_builder":
            return store.habitCheckIns >= 1
        case "consistent_performer":
            return store.longestStreak >= 7
        case "focused_hour":
            return store.totalFocusMinutes >= 60
        case "task_master":
            return store.tasksCompleted >= 10
        case "diligent_worker":
            return store.focusSessionsCompleted >= 50
        case "habit_pro":
            return store.habitCheckIns >= 50
        default:
            return false
        }
    }
}
