import SwiftUI

/// Static gradient background — no Canvas, no animation. Renders once per screen.
struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppGradients.screenBackground
            AppGradients.screenGlow
            AppGradients.screenGlowBottom
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
