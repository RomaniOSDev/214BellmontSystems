import SwiftUI

struct AppEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppGradients.iconFill)
                    .frame(width: 100, height: 100)
                    .overlay(Circle().stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: 1))
                    .compositingGroup()
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            if let actionTitle, let action {
                AppSecondaryButton(actionTitle, icon: "arrow.right") {
                    action()
                }
                .padding(.horizontal, 48)
                .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

struct AppMetricTile: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            AppIconCircle(icon: icon, size: 36, iconColor: Color("AppPrimary"))
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct AppMetricRow: View {
    let metrics: [(value: String, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { index, metric in
                if index > 0 {
                    Rectangle()
                        .fill(Color("AppTextPrimary").opacity(0.1))
                        .frame(width: 1, height: 40)
                }
                VStack(spacing: 4) {
                    Text(metric.value)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    Text(metric.label)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
