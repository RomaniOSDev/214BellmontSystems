import Charts
import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject private var store: AppDataStore

    private var review: WeeklyReviewData { store.weeklyReview() }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                metricsGrid
                focusChart
                insightsCard
            }
            .padding(.vertical, 16)
        }
    }

    private var heroCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    AppIconCircle(icon: "chart.bar.xaxis", size: 48, iconColor: Color("AppPrimary"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Review")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Your last 7 days at a glance")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(value: "\(review.tasksCompleted)", label: "Tasks Completed", icon: "checkmark.circle.fill")
            metricCard(value: "\(review.focusMinutes)", label: "Focus Minutes", icon: "timer")
            metricCard(value: "\(review.focusSessions)", label: "Focus Sessions", icon: "bolt.fill")
            metricCard(value: "\(review.habitCheckIns)", label: "Habit Check-ins", icon: "leaf.fill")
        }
        .padding(.horizontal, 16)
    }

    private func metricCard(value: String, label: String, icon: String) -> some View {
        AppCard(padding: 14) {
            VStack(spacing: 10) {
                AppIconCircle(icon: icon, size: 36, iconColor: Color("AppPrimary"))
                Text(value)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var focusChart: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Daily Focus")

                Chart(review.dailyFocusMinutes, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
        }
        .padding(.horizontal, 16)
    }

    private var insightsCard: some View {
        AppCard {
            HStack(alignment: .top, spacing: 14) {
                AppIconCircle(icon: "lightbulb.fill", size: 40, iconColor: Color("AppAccent"))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Planning Tip")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(insightText)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineSpacing(3)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var insightText: String {
        if review.tasksCompleted == 0 && review.focusSessions == 0 {
            return "Start with one task and a short focus session to build momentum."
        }
        if review.habitCheckIns < 3 {
            return "Try logging habits daily — consistency matters more than perfection."
        }
        if review.focusMinutes < 60 {
            return "Aim for at least 60 focus minutes this week to deepen your workflow."
        }
        return "Great progress this week. Review your tasks and set priorities for next week."
    }
}
