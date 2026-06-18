import Foundation

struct MomentumBreakdown {
    let total: Int
    let taskPoints: Int
    let focusPoints: Int
    let habitPoints: Int
    let streakPoints: Int
    let level: MomentumLevel

    enum MomentumLevel: String {
        case warming
        case building
        case flowing
        case unstoppable

        var displayName: String {
            switch self {
            case .warming: return "Warming Up"
            case .building: return "Building Flow"
            case .flowing: return "In the Flow"
            case .unstoppable: return "Unstoppable"
            }
        }

        var icon: String {
            switch self {
            case .warming: return "flame"
            case .building: return "flame.fill"
            case .flowing: return "bolt.fill"
            case .unstoppable: return "crown.fill"
            }
        }
    }
}

enum MomentumCalculator {
    static func breakdown(for store: AppDataStore) -> MomentumBreakdown {
        let review = store.weeklyReview()
        let taskPoints = min(review.tasksCompleted * 5, 25)
        let focusPoints = min(review.focusMinutes / 2, 35)
        let habitPoints = min(review.habitCheckIns * 3, 20)
        let streakPoints = min(store.streakDays * 2, 20)
        let total = min(taskPoints + focusPoints + habitPoints + streakPoints, 100)

        let level: MomentumBreakdown.MomentumLevel
        switch total {
        case 0..<25: level = .warming
        case 25..<50: level = .building
        case 50..<80: level = .flowing
        default: level = .unstoppable
        }

        return MomentumBreakdown(
            total: total,
            taskPoints: taskPoints,
            focusPoints: focusPoints,
            habitPoints: habitPoints,
            streakPoints: streakPoints,
            level: level
        )
    }
}
