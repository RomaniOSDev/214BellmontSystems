import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showWeeklyReview = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { $0.isUnlocked(store: store) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        let review = store.weeklyReview()
                        WeeklyReviewHeroCell(
                            tasksCompleted: review.tasksCompleted,
                            focusMinutes: review.focusMinutes,
                            habitCheckIns: review.habitCheckIns
                        ) {
                            showWeeklyReview = true
                        }
                        .padding(.horizontal, 16)

                        progressCard
                        achievementsGrid
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarStyle()
            .sheet(isPresented: $showWeeklyReview) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        WeeklyReviewView()
                    }
                    .navigationTitle("Weekly Review")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showWeeklyReview = false }
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appToolbarStyle()
                }
            }
        }
    }

    private var progressCard: some View {
        AppCard {
            VStack(spacing: 16) {
                HStack {
                    AppSectionHeader(
                        title: "Your Progress",
                        subtitle: "\(unlockedCount) of \(AchievementDefinition.all.count) achievements"
                    )
                    Spacer()
                    AppIconCircle(icon: "trophy.fill", size: 40, iconColor: Color("AppPrimary"))
                }

                AppMetricRow(metrics: [
                    ("\(store.tasksCompleted)", "Tasks"),
                    ("\(store.focusSessionsCompleted)", "Sessions"),
                    ("\(store.habitCheckIns)", "Check-ins")
                ])

                Divider().background(Color("AppTextPrimary").opacity(0.1))

                AppMetricRow(metrics: [
                    ("\(store.totalFocusMinutes)", "Focus Min"),
                    ("\(store.longestStreak)", "Best Streak"),
                    ("\(store.streakDays)", "Active Days")
                ])
            }
        }
        .padding(.horizontal, 16)
    }

    private var achievementsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Badges")
                .padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AchievementDefinition.all) { achievement in
                    AchievementCell(
                        achievement: achievement,
                        isUnlocked: achievement.isUnlocked(store: store)
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
