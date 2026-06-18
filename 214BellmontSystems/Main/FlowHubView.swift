import SwiftUI

struct FlowHubView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager
    @State private var selectedPhase: FlowPhase = .plan

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                Group {
                    switch selectedPhase {
                    case .plan:
                        PlanPhaseView()
                    case .execute:
                        ExecutePhaseView(selectedPhase: $selectedPhase)
                    case .review:
                        ReviewPhaseView(selectedPhase: $selectedPhase)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                FlowPhaseBar(selectedPhase: $selectedPhase)
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
            selectedPhase = .plan
        }
        .onAppear {
            store.refreshHabitsForToday()
            store.refreshWeeklyPlanIfNeeded()
            achievementManager.evaluate(store: store)
        }
    }
}
