import Combine
import Foundation
import SwiftUI

enum FocusPhase: String {
    case idle
    case focus
    case breakTime
}

@MainActor
final class FocusCycleViewModel: ObservableObject {
    @Published var phase: FocusPhase = .idle
    @Published var remainingSeconds: Int = 0
    @Published var currentSession: Int = 1
    @Published var isRunning = false
    @Published var showCustomize = false
    @Published var showSessionNoteSheet = false
    @Published var showTaskPicker = false
    @Published var pendingSessionId: UUID?

    let sessionsPerCycle = 4

    private var phaseEndDate: Date?
    private var pausedRemaining: Int = 0
    private var timerCancellable: AnyCancellable?
    private var isCompletingPhase = false
    private let store: AppDataStore
    private let achievementManager: AchievementManager

    init(store: AppDataStore, achievementManager: AchievementManager) {
        self.store = store
        self.achievementManager = achievementManager
    }

    var focusDurationMin: Int { store.focusDurationMin }
    var breakDurationMin: Int { store.breakDurationMin }
    var hasStarted: Bool { phase != .idle || store.focusSessionsCompleted > 0 }

    var sessionLabel: String {
        "Session \(currentSession) of \(sessionsPerCycle)"
    }

    var phaseLabel: String {
        switch phase {
        case .idle: return "Ready"
        case .focus: return "Focus"
        case .breakTime: return "Break"
        }
    }

    var linkedTaskLabel: String {
        if let task = store.selectedFocusTask {
            return task.title
        }
        return "No task linked"
    }

    var upcomingCardText: String {
        switch phase {
        case .idle:
            return "Next: \(store.focusDurationMin) min focus session"
        case .focus:
            return "Up next: \(store.breakDurationMin) min break"
        case .breakTime:
            if currentSession >= sessionsPerCycle {
                return "Cycle complete — start a new cycle"
            }
            return "Up next: Session \(currentSession + 1) focus"
        }
    }

    func formattedTime() -> String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func progress() -> Double {
        let total: Double
        switch phase {
        case .idle: return 0
        case .focus: total = Double(store.focusDurationMin * 60)
        case .breakTime: total = Double(store.breakDurationMin * 60)
        }
        guard total > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / total)
    }

    func start() {
        guard store.canStartFocus else {
            FeedbackService.warning()
            return
        }
        FeedbackService.mediumAction()
        if phase == .idle {
            beginFocus()
        } else if !isRunning {
            resume()
        }
    }

    func reset() {
        FeedbackService.lightTap()
        isRunning = false
        phase = .idle
        phaseEndDate = nil
        remainingSeconds = 0
        pausedRemaining = 0
        currentSession = 1
        stopTimer()
    }

    func pause() {
        guard isRunning, let end = phaseEndDate else { return }
        pausedRemaining = max(0, Int(end.timeIntervalSinceNow))
        remainingSeconds = pausedRemaining
        isRunning = false
        phaseEndDate = nil
        stopTimer()
    }

    func resume() {
        guard remainingSeconds > 0 else { return }
        phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        startTimer()
    }

    func handleScenePhase(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            if !isRunning && remainingSeconds > 0 && phase != .idle {
                resume()
            }
        case .inactive, .background:
            if isRunning {
                pause()
            }
        @unknown default:
            break
        }
    }

    private func tick(at date: Date) {
        guard isRunning, let end = phaseEndDate, !isCompletingPhase else { return }
        let left = max(0, Int(end.timeIntervalSince(date)))
        if remainingSeconds != left {
            remainingSeconds = left
        }
        guard left <= 0 else { return }
        stopTimer()
        completePhase()
    }

    private func startTimer() {
        stopTimer()
        guard isRunning else { return }
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.tick(at: date)
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func saveSessionNote(_ note: String) {
        guard let id = pendingSessionId else { return }
        store.updateFocusSessionNote(id: id, note: note)
        pendingSessionId = nil
        if !note.isEmpty {
            FeedbackService.success()
        }
    }

    func dismissSessionNote() {
        pendingSessionId = nil
        showSessionNoteSheet = false
    }

    private func beginFocus() {
        phase = .focus
        remainingSeconds = store.focusDurationMin * 60
        phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        startTimer()
    }

    private func completePhase() {
        guard !isCompletingPhase else { return }
        isCompletingPhase = true
        defer { isCompletingPhase = false }

        isRunning = false
        phaseEndDate = nil
        FeedbackService.focusPhaseCompleted()

        switch phase {
        case .focus:
            let sessionId = store.recordFocusSessionCompleted(
                minutes: store.focusDurationMin,
                sessionNumber: currentSession
            )
            pendingSessionId = sessionId
            showSessionNoteSheet = true
            achievementManager.evaluate(store: store)
            phase = .breakTime
            remainingSeconds = store.breakDurationMin * 60
            phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            isRunning = true
            startTimer()
        case .breakTime:
            if currentSession >= sessionsPerCycle {
                phase = .idle
                remainingSeconds = 0
                currentSession = 1
                stopTimer()
            } else {
                currentSession += 1
                phase = .focus
                remainingSeconds = store.focusDurationMin * 60
                phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
                isRunning = true
                startTimer()
            }
        case .idle:
            stopTimer()
        }
    }
}
