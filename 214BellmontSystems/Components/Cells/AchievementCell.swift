import SwiftUI

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Group {
                    if isUnlocked {
                        Circle().fill(AppGradients.primary)
                    } else {
                        Circle().fill(Color("AppBackground").opacity(0.6))
                    }
                }
                .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(
                                isUnlocked ? Color("AppTextPrimary").opacity(0.2) : Color("AppTextPrimary").opacity(0.06),
                                lineWidth: 1
                            )
                    )

                Image(systemName: achievement.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.4))
            }

            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }

            if isUnlocked {
                AppBadge(text: "Unlocked", style: .accent)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 160)
        .appDepth(.flat, cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isUnlocked ? Color("AppPrimary").opacity(0.35) : Color.clear,
                    lineWidth: 1
                )
        )
        .opacity(isUnlocked ? 1 : 0.75)
    }
}

struct WeeklyReviewHeroCell: View {
    let tasksCompleted: Int
    let focusMinutes: Int
    let habitCheckIns: Int
    let action: () -> Void

    var body: some View {
        AppCardButton(action: action, elevation: .medium) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            AppIconCircle(icon: "chart.bar.fill", size: 32, iconColor: Color("AppPrimary"))
                            Text("Weekly Review")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        Text("Last 7 days at a glance")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))
                }

                AppMetricRow(metrics: [
                    ("\(tasksCompleted)", "Tasks"),
                    ("\(focusMinutes)", "Minutes"),
                    ("\(habitCheckIns)", "Habits")
                ])
            }
        }
    }
}
