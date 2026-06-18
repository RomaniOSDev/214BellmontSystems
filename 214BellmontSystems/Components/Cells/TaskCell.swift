import SwiftUI

struct TaskCell: View {
    let task: TaskItem
    let focusMinutes: Int
    let isPulsing: Bool
    let onToggle: () -> Void
    let onOpen: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            priorityStripe

            HStack(spacing: 14) {
                checkboxButton
                contentButton
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.vertical, 14)
        }
        .background(
            ZStack {
                AppSurfaceShape(cornerRadius: 16)
                if isPulsing {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppAccent").opacity(0.2))
                } else if task.completed {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppBackground").opacity(0.25))
                }
            }
        )
        .overlay(AppHighlightBorder(cornerRadius: 16, opacity: 0.07))
        .animation(.easeInOut(duration: 0.35), value: isPulsing)
    }

    private var priorityStripe: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [priorityColor, priorityColor.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4)
            .padding(.vertical, 10)
            .padding(.leading, 4)
    }

    private var checkboxButton: some View {
        Button(action: onToggle) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(task.completed ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.5), lineWidth: 2)
                    .frame(width: 28, height: 28)
                if task.completed {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }

    private var contentButton: some View {
        Button(action: onOpen) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .strikethrough(task.completed, color: Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)

                    badgesRow

                    if let due = task.dueDate, !task.completed {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(due, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                        }
                        .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
            }
        }
        .buttonStyle(.plain)
    }

    private var badgesRow: some View {
        HStack(spacing: 6) {
            AppBadge(text: task.category, style: .neutral)
            EnergyBadge(level: task.energyLevel, compact: true)

            if task.isWeeklyPriority {
                AppBadge(text: "Week", style: .primary)
            }

            HStack(spacing: 3) {
                Circle().fill(priorityColor).frame(width: 6, height: 6)
                Text(task.priority.displayName)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            if let progress = task.subtasksProgress {
                HStack(spacing: 2) {
                    Image(systemName: "list.bullet")
                        .font(.caption2)
                    Text(progress)
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(Color("AppAccent"))
            }

            if focusMinutes > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "timer")
                        .font(.caption2)
                    Text("\(focusMinutes)m")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(Color("AppAccent"))
            }

            if task.isOverdue {
                AppBadge(text: "Overdue", style: .danger)
            } else if task.isDueToday {
                AppBadge(text: "Due Today", style: .primary)
            }
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: return Color("AppTextSecondary")
        case .medium: return Color("AppAccent")
        case .high: return Color("AppPrimary")
        }
    }
}
