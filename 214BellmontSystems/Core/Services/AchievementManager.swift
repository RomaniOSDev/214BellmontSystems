import Combine
import Foundation
import SwiftUI

@MainActor
final class AchievementManager: ObservableObject {
    @Published var currentBanner: AchievementDefinition?
    @Published private(set) var isShowingBanner = false

    private var queue: [AchievementDefinition] = []
    private var dismissTask: Task<Void, Never>?

    func evaluate(store: AppDataStore) {
        for achievement in AchievementDefinition.all {
            guard achievement.isUnlocked(store: store) else { continue }
            guard store.achievementsUnlocked[achievement.id] == nil else { continue }
            store.unlockAchievement(id: achievement.id)
            enqueue(achievement)
        }
    }

    private func enqueue(_ achievement: AchievementDefinition) {
        queue.append(achievement)
        guard !isShowingBanner else { return }
        showNext()
    }

    func resetBanners() {
        dismissTask?.cancel()
        queue.removeAll()
        currentBanner = nil
        isShowingBanner = false
    }

    private func showNext() {
        guard !queue.isEmpty else { return }
        let next = queue.removeFirst()
        currentBanner = next
        isShowingBanner = true
        FeedbackService.achievementUnlocked()

        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                isShowingBanner = false
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            currentBanner = nil
            showNext()
        }
    }
}
