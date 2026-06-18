import SwiftUI

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var isDestructive = false
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 14) {
                AppIconCircle(
                    icon: icon,
                    size: 40,
                    iconColor: isDestructive ? .red : Color("AppPrimary"),
                    backgroundOpacity: isDestructive ? 0.15 : 0.2
                )

                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

struct TemplateCell: View {
    let template: TaskTemplate
    let onUse: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AppIconCircle(icon: "doc.text.fill", size: 44, iconColor: Color("AppPrimary"))

            VStack(alignment: .leading, spacing: 6) {
                Text(template.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 8) {
                    AppBadge(text: template.category, style: .neutral)
                    EnergyBadge(level: template.energyLevel, compact: true)
                    HStack(spacing: 3) {
                        Circle()
                            .fill(priorityColor(template.priority))
                            .frame(width: 6, height: 6)
                        Text(template.priority.displayName)
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }

            Spacer()

            Button {
                FeedbackService.mediumAction()
                onUse()
            } label: {
                Text("Use")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .appPrimaryFill(cornerRadius: 20, glow: false)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .appDepth(.flat, cornerRadius: 14)
    }

    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return Color("AppTextSecondary")
        case .medium: return Color("AppAccent")
        case .high: return Color("AppPrimary")
        }
    }
}

struct SubtaskCell: View {
    let subtask: Subtask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(subtask.completed ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.4), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if subtask.completed {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color("AppAccent"))
                    }
                }

                Text(subtask.title)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .strikethrough(subtask.completed)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppGradients.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color("AppTextPrimary").opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
