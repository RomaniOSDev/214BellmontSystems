import Foundation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case completed
    case dueToday
    case overdue

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .completed: return "Completed"
        case .dueToday: return "Due Today"
        case .overdue: return "Overdue"
        }
    }
}

enum TaskSort: String, CaseIterable, Identifiable {
    case priority
    case dueDate
    case category
    case newest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .priority: return "Priority"
        case .dueDate: return "Due Date"
        case .category: return "Category"
        case .newest: return "Newest"
        }
    }
}
