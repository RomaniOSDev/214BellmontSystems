import SwiftUI

enum EnergyLevel: String, Codable, CaseIterable, Identifiable {
    case peak
    case steady
    case low

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .peak: return "Peak"
        case .steady: return "Steady"
        case .low: return "Low"
        }
    }

    var icon: String {
        switch self {
        case .peak: return "bolt.fill"
        case .steady: return "waveform.path"
        case .low: return "leaf.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .peak: return "Deep work & hard problems"
        case .steady: return "Steady output & collaboration"
        case .low: return "Admin, review & recovery"
        }
    }

    var accentColor: Color {
        switch self {
        case .peak: return Color("AppPrimary")
        case .steady: return Color("AppAccent")
        case .low: return Color("AppTextSecondary")
        }
    }
}
