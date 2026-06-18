import SwiftUI

enum FlowPhase: Int, CaseIterable, Identifiable {
    case plan
    case execute
    case review

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .plan: return "Plan"
        case .execute: return "Execute"
        case .review: return "Review"
        }
    }

    var subtitle: String {
        switch self {
        case .plan: return "Set your week"
        case .execute: return "Run the day"
        case .review: return "Measure flow"
        }
    }

    var icon: String {
        switch self {
        case .plan: return "calendar.badge.clock"
        case .execute: return "play.circle.fill"
        case .review: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct FlowPhaseBar: View {
    @Binding var selectedPhase: FlowPhase
    @State private var pressedPhase: FlowPhase?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(FlowPhase.allCases) { phase in
                phaseButton(for: phase)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppGradients.surfaceElevated)
        )
        .overlay(AppHighlightBorder(cornerRadius: 20))
        .compositingGroup()
        .shadow(color: .black.opacity(AppElevation.high.shadowOpacity), radius: AppElevation.high.shadowRadius, y: -2)
        .padding(.horizontal, 6)
    }

    private func phaseButton(for phase: FlowPhase) -> some View {
        let isSelected = selectedPhase == phase
        return Button {
            FeedbackService.lightTap()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedPhase = phase
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppGradients.primary)
                            .frame(width: 52, height: 32)
                            .overlay(Capsule().stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1))
                    }
                    Image(systemName: phase.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                }
                Text(phase.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(pressedPhase == phase ? 0.94 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedPhase = phase }
                .onEnded { _ in pressedPhase = nil }
        )
    }
}
