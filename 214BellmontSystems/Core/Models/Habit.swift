import Foundation

struct Habit: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var streakCount: Int
    var completedToday: Bool
    var lastCompletedDate: Date?
    var completedDates: [Date]

    init(
        id: UUID = UUID(),
        name: String,
        streakCount: Int = 0,
        completedToday: Bool = false,
        lastCompletedDate: Date? = nil,
        completedDates: [Date] = []
    ) {
        self.id = id
        self.name = name
        self.streakCount = streakCount
        self.completedToday = completedToday
        self.lastCompletedDate = lastCompletedDate
        self.completedDates = completedDates
    }

    enum CodingKeys: String, CodingKey {
        case id, name, streakCount, completedToday, lastCompletedDate, completedDates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        streakCount = try container.decode(Int.self, forKey: .streakCount)
        completedToday = try container.decode(Bool.self, forKey: .completedToday)
        lastCompletedDate = try container.decodeIfPresent(Date.self, forKey: .lastCompletedDate)
        completedDates = try container.decodeIfPresent([Date].self, forKey: .completedDates) ?? []
    }
}
