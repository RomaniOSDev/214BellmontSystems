import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let icon: String
    let badge: String
    let imageName: String
    let highlights: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            headline: "Organize Tasks",
            description: "Keep track of your tasks effortlessly to stay on top of your workload.",
            icon: "checklist",
            badge: "Tasks",
            imageName: "home_tasks_widget",
            highlights: ["Priorities", "Due Dates", "Templates"]
        ),
        OnboardingPage(
            id: 1,
            headline: "Initiate Focus Sessions",
            description: "Start a focus timer with just a tap to minimize distractions.",
            icon: "timer",
            badge: "Focus",
            imageName: "home_focus_widget",
            highlights: ["Pomodoro", "Sessions", "Notes"]
        ),
        OnboardingPage(
            id: 2,
            headline: "Build Habits",
            description: "Consistently log and track habits to reinforce positive behavior change.",
            icon: "leaf.fill",
            badge: "Habits",
            imageName: "home_habits_widget",
            highlights: ["Streaks", "Calendar", "Daily Log"]
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        onboardingPageView(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomControls
            }
        }
    }

    private var topBar: some View {
        HStack {
            AppBadge(text: "Step \(currentPage + 1) of \(pages.count)", style: .neutral)
            Spacer()
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    FeedbackService.lightTap()
                    store.completeOnboarding()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 20) {
            pageIndicator

            AppPrimaryButton(
                currentPage < pages.count - 1 ? "Next" : "Get Started",
                icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
            ) {
                FeedbackService.mediumAction()
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
                } else {
                    store.completeOnboarding()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Group {
                    if index == currentPage {
                        Capsule().fill(AppGradients.primary)
                    } else {
                        Capsule().fill(Color("AppTextSecondary").opacity(0.25))
                    }
                }
                .frame(width: index == currentPage ? 28 : 8, height: 8)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .appDepth(.flat, cornerRadius: 20)
    }

    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            Spacer()

            OnboardingHeroCard(page: page)
                .padding(.horizontal, 24)
                .id(page.id)

            AppCard(elevation: .medium) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        AppIconCircle(icon: page.icon, size: 48, iconColor: Color("AppPrimary"))
                        VStack(alignment: .leading, spacing: 6) {
                            Text(page.headline)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            AppBadge(text: page.badge, style: .accent)
                        }
                    }

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    highlightsRow(page.highlights)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func highlightsRow(_ highlights: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(highlights, id: \.self) { highlight in
                AppBadge(text: highlight, style: .neutral)
            }
        }
    }
}

// MARK: - Hero Card

private struct OnboardingHeroCard: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(page.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(spacing: 10) {
                AppIconCircle(icon: page.icon, size: 36, iconColor: Color("AppAccent"))
                Text(page.badge)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color("AppTextPrimary").opacity(0.18),
                            Color("AppPrimary").opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .compositingGroup()
        .shadow(color: .black.opacity(AppElevation.high.shadowOpacity), radius: AppElevation.high.shadowRadius, y: AppElevation.high.shadowY)
        .scaleEffect(appeared ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) { appeared = true }
        }
    }
}
