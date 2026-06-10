import Combine
import Foundation

@MainActor
final class DailyHabitLogViewModel: ObservableObject {
    @Published var showAddHabit = false
    @Published var editingHabit: Habit?
    @Published var highlightHabitID: UUID?

    private let store: AppDataStore
    private let achievementManager: AchievementManager

    init(store: AppDataStore, achievementManager: AchievementManager) {
        self.store = store
        self.achievementManager = achievementManager
    }

    var habits: [Habit] {
        store.habits
    }

    func addHabit(name: String) {
        store.addHabit(name: name)
        FeedbackService.success()
        achievementManager.evaluate(store: store)
    }

    func updateHabit(_ habit: Habit) {
        store.updateHabit(habit)
        FeedbackService.success()
    }

    func deleteHabit(id: UUID) {
        store.deleteHabit(id: id)
        FeedbackService.lightTap()
    }

    func checkIn(id: UUID) {
        let success = store.checkInHabit(id: id)
        if success {
            FeedbackService.habitCheckIn()
            FeedbackService.success()
            highlightHabitID = id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.highlightHabitID = nil
            }
            achievementManager.evaluate(store: store)
        } else {
            FeedbackService.lightTap()
        }
    }
}
