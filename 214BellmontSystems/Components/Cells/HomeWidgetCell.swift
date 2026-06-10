import SwiftUI

struct HomeStatWidget: View {
    let value: String
    let label: String
    let icon: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AppIconCircle(icon: icon, size: 32, iconColor: accent, backgroundOpacity: 0.22)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appDepth(.medium, cornerRadius: 16)
    }
}

struct HomeFeatureWidget: View {
    let title: String
    let subtitle: String
    let imageName: String
    let metrics: [(String, String)]
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }

                    HStack(spacing: 16) {
                        ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(metric.0)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(Color("AppPrimary"))
                                Text(metric.1)
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }

                    HStack(spacing: 4) {
                        Text("Open")
                            .font(.caption.weight(.bold))
                        Image(systemName: "arrow.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110)
                    .clipped()
            }
            .frame(height: 150)
            .appDepth(.medium, cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

struct HomeQuickAction: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            VStack(spacing: 8) {
                AppIconCircle(icon: icon, size: 48, iconColor: Color("AppPrimary"))
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .appDepth(.flat, cornerRadius: 14)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

struct HomeTaskPreviewRow: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(task.completed ? Color("AppAccent") : Color("AppTextSecondary"))
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            if task.isDueToday {
                AppBadge(text: "Today", style: .primary)
            } else if task.isOverdue {
                AppBadge(text: "Late", style: .danger)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppGradients.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color("AppTextPrimary").opacity(0.06), lineWidth: 1)
        )
    }
}
