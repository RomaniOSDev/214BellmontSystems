import SwiftUI

// MARK: - Gradients (static, no animation — GPU-friendly)

enum AppGradients {
    static let screenBackground = LinearGradient(
        colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenGlow = RadialGradient(
        colors: [Color("AppPrimary").opacity(0.14), Color.clear],
        center: .topTrailing,
        startRadius: 10,
        endRadius: 320
    )

    static let screenGlowBottom = RadialGradient(
        colors: [Color("AppAccent").opacity(0.08), Color.clear],
        center: .bottomLeading,
        startRadius: 10,
        endRadius: 280
    )

    static let surface = LinearGradient(
        colors: [
            Color("AppSurface"),
            Color("AppSurface").opacity(0.92),
            Color("AppBackground").opacity(0.35)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceElevated = LinearGradient(
        colors: [
            Color("AppSurface").opacity(1),
            Color("AppSurface").opacity(0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let primary = LinearGradient(
        colors: [Color("AppAccent"), Color("AppPrimary")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = LinearGradient(
        colors: [Color("AppPrimary"), Color("AppAccent")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let stripe = LinearGradient(
        colors: [Color("AppPrimary").opacity(0.6), Color("AppAccent").opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let progress = LinearGradient(
        colors: [Color("AppPrimary"), Color("AppAccent")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let iconFill = LinearGradient(
        colors: [Color("AppPrimary").opacity(0.28), Color("AppAccent").opacity(0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Elevation

enum AppElevation {
  /// Scroll lists — border + gradient only, zero shadow (60fps)
    case flat
  /// Chips, small controls
    case low
  /// Cards, sections (max ~8 visible)
    case medium
  /// Tab bar, FAB, hero — single shadow layer
    case high

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 3
        case .medium: return 6
        case .high: return 10
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 1
        case .medium: return 3
        case .high: return 5
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .low: return 0.1
        case .medium: return 0.14
        case .high: return 0.2
        }
    }
}

// MARK: - Shape helpers

struct AppSurfaceShape: View {
    var cornerRadius: CGFloat = 16

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.surface)
    }
}

struct AppHighlightBorder: View {
    var cornerRadius: CGFloat = 16
    var opacity: Double = 0.12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color("AppTextPrimary").opacity(opacity),
                        Color("AppTextPrimary").opacity(opacity * 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

// MARK: - View modifiers

struct AppDepthModifier: ViewModifier {
    let elevation: AppElevation
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if elevation == .flat {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.surface)
                )
                .overlay(AppHighlightBorder(cornerRadius: cornerRadius, opacity: 0.08))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.surfaceElevated)
                )
                .overlay(AppHighlightBorder(cornerRadius: cornerRadius))
                .compositingGroup()
                .shadow(
                    color: .black.opacity(elevation.shadowOpacity),
                    radius: elevation.shadowRadius,
                    y: elevation.shadowY
                )
        }
    }
}

struct AppPrimaryFillModifier: ViewModifier {
    let cornerRadius: CGFloat
    let withGlow: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppGradients.primary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color("AppTextPrimary").opacity(0.15), lineWidth: 1)
            )
            .compositingGroup()
            .shadow(
                color: withGlow ? Color("AppPrimary").opacity(0.3) : .clear,
                radius: withGlow ? 8 : 0,
                y: withGlow ? 4 : 0
            )
    }
}

extension View {
    func appDepth(_ elevation: AppElevation = .medium, cornerRadius: CGFloat = 16) -> some View {
        modifier(AppDepthModifier(elevation: elevation, cornerRadius: cornerRadius))
    }

    func appPrimaryFill(cornerRadius: CGFloat = 14, glow: Bool = true) -> some View {
        modifier(AppPrimaryFillModifier(cornerRadius: cornerRadius, withGlow: glow))
    }
}
