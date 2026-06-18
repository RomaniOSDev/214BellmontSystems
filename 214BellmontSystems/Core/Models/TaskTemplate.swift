import Foundation

struct TaskTemplate: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var category: String
    var priority: TaskPriority
    var energyLevel: EnergyLevel

    init(
        id: UUID = UUID(),
        title: String,
        category: String = "General",
        priority: TaskPriority = .medium,
        energyLevel: EnergyLevel = .steady
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.priority = priority
        self.energyLevel = energyLevel
    }

    static let defaults: [TaskTemplate] = [
        TaskTemplate(title: "Ship client deliverable", category: "Work", priority: .high, energyLevel: .peak),
        TaskTemplate(title: "Outline next deep work block", category: "Work", priority: .high, energyLevel: .peak),
        TaskTemplate(title: "Review weekly outcomes", category: "Work", priority: .medium, energyLevel: .steady),
        TaskTemplate(title: "Clear admin backlog", category: "Personal", priority: .low, energyLevel: .low),
        TaskTemplate(title: "Learning deep dive", category: "Learning", priority: .medium, energyLevel: .peak),
        TaskTemplate(title: "Friday flow reset", category: "Work", priority: .medium, energyLevel: .steady)
    ]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(String.self, forKey: .category)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        energyLevel = try container.decodeIfPresent(EnergyLevel.self, forKey: .energyLevel) ?? .steady
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, category, priority, energyLevel
    }
}
