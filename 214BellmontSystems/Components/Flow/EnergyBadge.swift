import SwiftUI

struct EnergyBadge: View {
    let level: EnergyLevel
    var compact = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.icon)
                .font(.caption2.weight(.bold))
            if !compact {
                Text(level.displayName)
                    .font(.caption2.weight(.bold))
            }
        }
        .foregroundStyle(Color("AppTextPrimary"))
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, 3)
        .background(
            Capsule(style: .continuous)
                .fill(level.accentColor.opacity(0.35))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(level.accentColor.opacity(0.5), lineWidth: 1)
        )
    }
}

struct EnergyLevelPicker: View {
    @Binding var selection: EnergyLevel

    var body: some View {
        HStack(spacing: 8) {
            ForEach(EnergyLevel.allCases) { level in
                Button {
                    FeedbackService.lightTap()
                    selection = level
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: level.icon)
                            .font(.body.weight(.semibold))
                        Text(level.displayName)
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(selection == level ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selection == level ? level.accentColor.opacity(0.3) : Color("AppBackground").opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(selection == level ? level.accentColor.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
