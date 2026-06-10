import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private let store: AppDataStore
    private var cancellable: AnyCancellable?

    init(store: AppDataStore) {
        self.store = store
        cancellable = store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var formattedDate: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var activeTasks: Int {
        store.tasks.filter { !$0.completed }.count
    }

    var dueTodayCount: Int {
        store.tasks.filter(\.isDueToday).count
    }

    var overdueCount: Int {
        store.tasks.filter(\.isOverdue).count
    }

    var habitsDoneToday: Int {
        store.habits.filter(\.completedToday).count
    }

    var habitsTotal: Int {
        store.habits.count
    }

    var todayFocusMinutes: Int {
        sessionsToday.reduce(0) { $0 + $1.durationMinutes }
    }

    var todayFocusSessions: Int {
        sessionsToday.count
    }

    var streakDays: Int {
        store.streakDays
    }

    var weeklyReview: WeeklyReviewData {
        store.weeklyReview()
    }

    var upcomingTasks: [TaskItem] {
        store.filteredAndSortedTasks(filter: .active, sort: .dueDate).prefix(4).map { $0 }
    }

    var unlockedAchievements: Int {
        AchievementDefinition.all.filter { $0.isUnlocked(store: store) }.count
    }

    private var sessionsToday: [FocusSessionRecord] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        return store.focusSessionHistory.filter { $0.date >= start && $0.date < end }
    }
}
