import Combine
import Foundation

@MainActor
final class TaskOrganizerViewModel: ObservableObject {
    @Published var showAddTask = false
    @Published var editingTask: TaskItem?
    @Published var showTaskSettings = false
    @Published var successCheckmark = false
    @Published var pulsingTaskID: UUID?

    private let store: AppDataStore
    private let achievementManager: AchievementManager

    init(store: AppDataStore, achievementManager: AchievementManager) {
        self.store = store
        self.achievementManager = achievementManager
    }

    var tasks: [TaskItem] {
        store.tasks
    }

    var defaultCategory: String {
        get { store.defaultCategory }
        set { store.defaultCategory = newValue }
    }

    var incompleteTasks: [TaskItem] {
        store.tasks.filter { !$0.completed }
    }

    var completedTasks: [TaskItem] {
        store.tasks.filter { $0.completed }
    }

    func addTask(title: String, category: String, priority: TaskPriority) {
        let task = TaskItem(title: title, category: category, priority: priority)
        store.addTask(task)
        FeedbackService.success()
        achievementManager.evaluate(store: store)
    }

    func updateTask(_ task: TaskItem) {
        store.updateTask(task)
        FeedbackService.success()
    }

    func deleteTask(id: UUID) {
        store.deleteTask(id: id)
        FeedbackService.lightTap()
    }

    func toggleCompletion(id: UUID) {
        let completed = store.toggleTaskCompletion(id: id)
        if completed {
            FeedbackService.taskCompleted()
            pulsingTaskID = id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.pulsingTaskID = nil
            }
            achievementManager.evaluate(store: store)
        } else {
            FeedbackService.lightTap()
        }
    }
}
