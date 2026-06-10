import Charts
import SwiftUI

struct FocusSessionHistoryView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if store.focusSessionHistory.isEmpty {
                    AppEmptyState(
                        icon: "clock.arrow.circlepath",
                        title: "No sessions yet",
                        message: "Complete a focus session to see your history and progress chart here."
                    )
                } else {
                    chartSection
                    sessionsList
                }
            }
            .padding(.vertical, 16)
        }
    }

    private var chartSection: some View {
        let review = store.weeklyReview()

        return AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Focus Minutes", subtitle: "Last 7 days")

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
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(.horizontal, 16)
    }

    private var sessionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Recent Sessions")
                .padding(.horizontal, 16)

            LazyVStack(spacing: 10) {
                ForEach(store.focusSessionHistory) { session in
                    FocusSessionCell(session: session)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
