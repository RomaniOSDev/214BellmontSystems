import SwiftUI

struct MomentumScoreCard: View {
    let breakdown: MomentumBreakdown
    var showBreakdown = true

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Momentum Score")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        HStack(spacing: 6) {
                            Image(systemName: breakdown.level.icon)
                                .foregroundStyle(Color("AppAccent"))
                            Text(breakdown.level.displayName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    Spacer()
                    Text("\(breakdown.total)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppPrimary"))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("AppBackground").opacity(0.5))
                            .frame(height: 10)
                        Capsule()
                            .fill(AppGradients.progress)
                            .frame(width: geo.size.width * CGFloat(breakdown.total) / 100, height: 10)
                    }
                }
                .frame(height: 10)

                if showBreakdown {
                    HStack(spacing: 0) {
                        breakdownItem(value: breakdown.taskPoints, label: "Tasks", max: 25)
                        breakdownItem(value: breakdown.focusPoints, label: "Focus", max: 35)
                        breakdownItem(value: breakdown.habitPoints, label: "Habits", max: 20)
                        breakdownItem(value: breakdown.streakPoints, label: "Streak", max: 20)
                    }
                }
            }
        }
    }

    private func breakdownItem(value: Int, label: String, max: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
            Text("/\(max)")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}
