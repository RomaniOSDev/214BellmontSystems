import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab, store: store)
                    case .tasks:
                        TaskOrganizerView()
                    case .productivity:
                        ProductivityHubView()
                    case .achievements:
                        AchievementsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab)
            }

            if achievementManager.isShowingBanner, let banner = achievementManager.currentBanner {
                AchievementBannerView(achievement: banner)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: achievementManager.isShowingBanner)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            selectedTab = .home
        }
        .onAppear {
            store.refreshHabitsForToday()
            achievementManager.evaluate(store: store)
        }
    }
}
