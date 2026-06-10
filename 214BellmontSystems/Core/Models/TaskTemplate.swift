import Foundation

struct TaskTemplate: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var category: String
    var priority: TaskPriority

    init(
        id: UUID = UUID(),
        title: String,
        category: String = "General",
        priority: TaskPriority = .medium
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.priority = priority
    }

    static let defaults: [TaskTemplate] = [
        TaskTemplate(title: "Weekly Report", category: "Work", priority: .medium),
        TaskTemplate(title: "Team Sync", category: "Work", priority: .high),
        TaskTemplate(title: "Inbox Review", category: "Personal", priority: .low),
        TaskTemplate(title: "Learning Session", category: "Learning", priority: .medium)
    ]
}
