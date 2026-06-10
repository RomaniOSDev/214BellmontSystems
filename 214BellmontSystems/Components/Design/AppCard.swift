import SwiftUI

struct AppCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    var elevation: AppElevation = .medium
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .appDepth(elevation, cornerRadius: cornerRadius)
    }
}

struct AppCardButton<Content: View>: View {
    let action: () -> Void
    var elevation: AppElevation = .medium
    @ViewBuilder let content: Content
    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            content
                .padding(16)
                .appDepth(elevation, cornerRadius: 16)
                .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}
