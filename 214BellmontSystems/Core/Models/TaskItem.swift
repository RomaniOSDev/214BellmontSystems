import Foundation

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

struct TaskItem: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var completed: Bool
    var category: String
    var priority: TaskPriority
    var dueDate: Date?
    var subtasks: [Subtask]
    var completedAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        completed: Bool = false,
        category: String = "General",
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        subtasks: [Subtask] = [],
        completedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.completed = completed
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.subtasks = subtasks
        self.completedAt = completedAt
        self.createdAt = createdAt
    }

    var subtasksProgress: String? {
        guard !subtasks.isEmpty else { return nil }
        let done = subtasks.filter(\.completed).count
        return "\(done)/\(subtasks.count)"
    }

    var isOverdue: Bool {
        guard let due = dueDate, !completed else { return false }
        return Calendar.current.startOfDay(for: due) < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let due = dueDate, !completed else { return false }
        return Calendar.current.isDateInToday(due)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, completed, category, priority
        case dueDate, subtasks, completedAt, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        completed = try container.decode(Bool.self, forKey: .completed)
        category = try container.decode(String.self, forKey: .category)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        subtasks = try container.decodeIfPresent([Subtask].self, forKey: .subtasks) ?? []
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
