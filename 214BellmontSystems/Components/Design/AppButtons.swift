import SwiftUI

struct AppPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    @State private var isPressed = false

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .appPrimaryFill(cornerRadius: 14)
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct AppSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .appDepth(.flat, cornerRadius: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

struct AppIconCircle: View {
    let icon: String
    var size: CGFloat = 44
    var iconColor: Color = Color("AppPrimary")
    var backgroundOpacity: Double = 0.2

    var body: some View {
        ZStack {
            Circle()
                .fill(AppGradients.iconFill)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(iconColor.opacity(0.2), lineWidth: 1)
                )
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(iconColor)
        }
    }
}

struct AppFloatingButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body.weight(.bold))
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Capsule(style: .continuous).fill(AppGradients.primary))
            .overlay(Capsule(style: .continuous).stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1))
            .compositingGroup()
            .shadow(color: Color("AppPrimary").opacity(0.35), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}
