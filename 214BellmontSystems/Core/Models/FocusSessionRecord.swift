import Foundation

struct FocusSessionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var durationMinutes: Int
    var sessionNumber: Int
    var linkedTaskId: UUID?
    var linkedTaskTitle: String?
    var note: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        durationMinutes: Int,
        sessionNumber: Int,
        linkedTaskId: UUID? = nil,
        linkedTaskTitle: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.sessionNumber = sessionNumber
        self.linkedTaskId = linkedTaskId
        self.linkedTaskTitle = linkedTaskTitle
        self.note = note
    }
}
