import Foundation

struct FlowBlock: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var startHour: Int
    var startMinute: Int
    var durationMinutes: Int
    var energyLevel: EnergyLevel
    var linkedTaskId: UUID?
    var isCompleted: Bool
    var scheduledDay: Date

    init(
        id: UUID = UUID(),
        title: String,
        startHour: Int,
        startMinute: Int = 0,
        durationMinutes: Int,
        energyLevel: EnergyLevel,
        linkedTaskId: UUID? = nil,
        isCompleted: Bool = false,
        scheduledDay: Date = Calendar.current.startOfDay(for: Date())
    ) {
        self.id = id
        self.title = title
        self.startHour = startHour
        self.startMinute = startMinute
        self.durationMinutes = durationMinutes
        self.energyLevel = energyLevel
        self.linkedTaskId = linkedTaskId
        self.isCompleted = isCompleted
        self.scheduledDay = Calendar.current.startOfDay(for: scheduledDay)
    }

    var timeLabel: String {
        String(format: "%02d:%02d", startHour, startMinute)
    }

    var durationLabel: String {
        durationMinutes >= 60
            ? "\(durationMinutes / 60)h \(durationMinutes % 60 > 0 ? "\(durationMinutes % 60)m" : "")".trimmingCharacters(in: .whitespaces)
            : "\(durationMinutes)m"
    }
}
