import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()
    @StateObject private var achievementManager = AchievementManager()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environmentObject(achievementManager)
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            achievementManager.resetBanners()
        }
    }
}

#Preview {
    ContentView()
}
