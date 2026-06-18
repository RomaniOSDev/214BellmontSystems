import SwiftUI

struct FlowBlockCell: View {
    let block: FlowBlock
    let onToggle: () -> Void
    var onStartFocus: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: block.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(block.isCompleted ? Color("AppAccent") : Color("AppTextSecondary"))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(block.timeLabel)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                        .monospacedDigit()
                    Text("·")
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(block.durationLabel)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    EnergyBadge(level: block.energyLevel, compact: true)
                }

                Text(block.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(block.isCompleted ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(block.isCompleted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            if let onStartFocus, !block.isCompleted, block.energyLevel == .peak {
                Button(action: onStartFocus) {
                    Image(systemName: "play.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(10)
                        .background(Circle().fill(AppGradients.primary))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .appDepth(.flat, cornerRadius: 14)
        .opacity(block.isCompleted ? 0.75 : 1)
    }
}

struct GuidedRoutineCard: View {
    let routine: GuidedRoutine
    let onApply: () -> Void

    var body: some View {
        AppCard(padding: 14, elevation: .flat) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    AppIconCircle(icon: routine.icon, size: 40, iconColor: Color("AppPrimary"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(routine.description)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }

                HStack(spacing: 6) {
                    AppBadge(text: "\(routine.steps.count) blocks", style: .neutral)
                    AppBadge(text: "\(routine.steps.reduce(0) { $0 + $1.durationMinutes }) min", style: .accent)
                }

                Button {
                    FeedbackService.mediumAction()
                    onApply()
                } label: {
                    HStack(spacing: 4) {
                        Text("Apply to Today")
                            .font(.caption.weight(.bold))
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption)
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
