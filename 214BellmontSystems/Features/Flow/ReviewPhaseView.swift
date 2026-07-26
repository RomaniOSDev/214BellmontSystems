import SwiftUI

struct ReviewPhaseView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedPhase: FlowPhase
    @State private var showAchievements = false
    @State private var showSettings = false

    private var breakdown: MomentumBreakdown { store.momentumBreakdown }
    private var review: WeeklyReviewData { store.weeklyReview() }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        reviewHeader
                        MomentumHeroBanner(breakdown: breakdown)
                            .padding(.horizontal, 16)
                        WeeklyCommitmentCard()
                            .padding(.horizontal, 16)
                        weeklyMetrics
                        WeeklyReviewView(embedded: true)
                        nextWeekCTA
                    }
                    .padding(.vertical, 12)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                        Button { showAchievements = true } label: {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                }
            }
            .appToolbarStyle()
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        SettingsView()
                    }
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showSettings = false }
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appToolbarStyle()
                }
            }
            .sheet(isPresented: $showAchievements) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        AchievementsView()
                    }
                    .navigationTitle("Flow Badges")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showAchievements = false }
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appToolbarStyle()
                }
            }
            .onAppear {
                store.markCommitmentKeptIfNeeded()
            }
        }
    }

    private var reviewHeader: some View {
        AppCard {
            HStack(spacing: 14) {
                AppIconCircle(icon: "chart.line.uptrend.xyaxis", size: 48, iconColor: Color("AppAccent"))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Momentum Scorecard")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Weekly Commitment · Energy · Outcomes")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var weeklyMetrics: some View {
        AppCard {
            AppMetricRow(metrics: [
                ("\(review.tasksCompleted)", "Outcomes"),
                ("\(review.focusMinutes)m", "Focus"),
                ("\(review.habitCheckIns)", "Anchors")
            ])
        }
        .padding(.horizontal, 16)
    }

    private var nextWeekCTA: some View {
        AppCardButton {
            selectedPhase = .plan
        } content: {
            HStack(spacing: 14) {
                AppIconCircle(icon: "arrow.triangle.2.circlepath", size: 44, iconColor: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Next Week's Plan")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Close the loop: Review → Plan → Execute")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
    }
}
