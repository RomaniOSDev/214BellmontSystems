import SwiftUI

struct AppChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(_ title: String, icon: String? = nil, isSelected: Bool = false, action: @escaping () -> Void = {}) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(chipBackground)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(
                        isSelected
                            ? Color("AppTextPrimary").opacity(0.15)
                            : Color("AppTextPrimary").opacity(0.1),
                        lineWidth: 1
                    )
            )
            .compositingGroup()
            .shadow(
                color: isSelected ? Color("AppPrimary").opacity(0.25) : .clear,
                radius: isSelected ? 4 : 0,
                y: isSelected ? 2 : 0
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            Capsule(style: .continuous).fill(AppGradients.primary)
        } else {
            Capsule(style: .continuous).fill(AppGradients.surface)
        }
    }
}

struct AppBadge: View {
    let text: String
    let style: BadgeStyle

    enum BadgeStyle {
        case primary, accent, danger, neutral

        @ViewBuilder
        var fill: some View {
            switch self {
            case .primary:
                Capsule(style: .continuous).fill(AppGradients.primary)
            case .accent:
                Capsule(style: .continuous).fill(AppGradients.accent)
            case .danger:
                Capsule(style: .continuous).fill(Color.red.opacity(0.75))
            case .neutral:
                Capsule(style: .continuous).fill(Color("AppBackground").opacity(0.55))
            }
        }
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(style.fill)
    }
}

struct AppSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
