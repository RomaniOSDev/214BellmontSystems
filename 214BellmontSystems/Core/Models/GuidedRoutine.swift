import Foundation

struct GuidedRoutineStep: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let durationMinutes: Int
    let energyLevel: EnergyLevel
    let startHour: Int
    let startMinute: Int
}

struct GuidedRoutine: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let steps: [GuidedRoutineStep]

    static let all: [GuidedRoutine] = [
        GuidedRoutine(
            id: "morning_ignition",
            name: "Morning Ignition",
            description: "Prime your brain before deep work starts.",
            icon: "sunrise.fill",
            steps: [
                GuidedRoutineStep(title: "Clarify top outcome", durationMinutes: 10, energyLevel: .steady, startHour: 8, startMinute: 0),
                GuidedRoutineStep(title: "Inbox sweep", durationMinutes: 15, energyLevel: .low, startHour: 8, startMinute: 10),
                GuidedRoutineStep(title: "Deep work block", durationMinutes: 50, energyLevel: .peak, startHour: 8, startMinute: 30)
            ]
        ),
        GuidedRoutine(
            id: "deep_work_sprint",
            name: "Deep Work Sprint",
            description: "A protected 90-minute focus window for hard problems.",
            icon: "brain.head.profile",
            steps: [
                GuidedRoutineStep(title: "Environment reset", durationMinutes: 5, energyLevel: .low, startHour: 10, startMinute: 0),
                GuidedRoutineStep(title: "Deep work sprint", durationMinutes: 90, energyLevel: .peak, startHour: 10, startMinute: 5)
            ]
        ),
        GuidedRoutine(
            id: "client_delivery",
            name: "Client Delivery Block",
            description: "Ship meaningful output with a clear finish line.",
            icon: "paperplane.fill",
            steps: [
                GuidedRoutineStep(title: "Scope deliverable", durationMinutes: 15, energyLevel: .steady, startHour: 14, startMinute: 0),
                GuidedRoutineStep(title: "Build & polish", durationMinutes: 60, energyLevel: .peak, startHour: 14, startMinute: 15),
                GuidedRoutineStep(title: "Send & log", durationMinutes: 10, energyLevel: .low, startHour: 15, startMinute: 15)
            ]
        ),
        GuidedRoutine(
            id: "friday_flow_reset",
            name: "Friday Flow Reset",
            description: "Close the week and set up the next one.",
            icon: "arrow.triangle.2.circlepath",
            steps: [
                GuidedRoutineStep(title: "Review wins", durationMinutes: 20, energyLevel: .steady, startHour: 16, startMinute: 0),
                GuidedRoutineStep(title: "Clear loose ends", durationMinutes: 25, energyLevel: .low, startHour: 16, startMinute: 20),
                GuidedRoutineStep(title: "Plan next week", durationMinutes: 30, energyLevel: .steady, startHour: 16, startMinute: 45)
            ]
        )
    ]

    func makeFlowBlocks(for day: Date = Date()) -> [FlowBlock] {
        steps.map { step in
            FlowBlock(
                title: step.title,
                startHour: step.startHour,
                startMinute: step.startMinute,
                durationMinutes: step.durationMinutes,
                energyLevel: step.energyLevel,
                scheduledDay: day
            )
        }
    }
}
