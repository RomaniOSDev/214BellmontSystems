import SwiftUI

enum ProductivitySection: String, CaseIterable, Identifiable {
    case focus
    case habits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus: return "Focus Cycle"
        case .habits: return "Daily Habit Log"
        }
    }

    var icon: String {
        switch self {
        case .focus: return "timer"
        case .habits: return "leaf.fill"
        }
    }
}

struct ProductivityHubView: View {
    @State private var selectedSection: ProductivitySection = .focus

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    sectionPicker
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    TabView(selection: $selectedSection) {
                        FocusCycleView()
                            .tag(ProductivitySection.focus)

                        DailyHabitLogView()
                            .tag(ProductivitySection.habits)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: selectedSection)
                }
            }
            .navigationTitle(selectedSection.title)
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarStyle()
        }
    }

    private var sectionPicker: some View {
        HStack(spacing: 8) {
            ForEach(ProductivitySection.allCases) { section in
                let isSelected = selectedSection == section
                Button {
                    FeedbackService.lightTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedSection = section
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: section.icon)
                            .font(.subheadline.weight(.semibold))
                        Text(section.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppGradients.primary)
                            } else {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppGradients.surface)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("AppTextPrimary").opacity(isSelected ? 0.12 : 0.06), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .appDepth(.flat, cornerRadius: 16)
    }
}
