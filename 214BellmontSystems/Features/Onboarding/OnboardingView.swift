import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var step = 0
    @State private var intention = ""
    @State private var selectedEnergy: EnergyLevel = .steady
    @State private var outcome = ""

    private let totalSteps = 4

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                HStack {
                    AppBadge(text: "Step \(step + 1) of \(totalSteps)", style: .neutral)
                    Spacer()
                    if step < totalSteps - 1 {
                        Button("Skip") {
                            FeedbackService.lightTap()
                            store.completeOnboarding()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    intentionStep.tag(1)
                    energyStep.tag(2)
                    outcomeStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: step)

                bottomControls
            }
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            MomentumHeroBanner(breakdown: MomentumBreakdown(
                total: 0,
                taskPoints: 0,
                focusPoints: 0,
                habitPoints: 0,
                streakPoints: 0,
                level: .warming
            ))
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Text("Weekly Flow")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Plan with energy. Execute one outcome. Review Momentum Score.")
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }

    private var intentionStep: some View {
        VStack(spacing: 20) {
            Spacer()
            AppCard {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(title: "Weekly Intention", subtitle: "One sentence for this week")
                    TextField("e.g. Ship client proposal by Thursday", text: $intention, axis: .vertical)
                        .lineLimit(2...4)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("AppBackground").opacity(0.45))
                        )
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
        }
    }

    private var energyStep: some View {
        VStack(spacing: 20) {
            Spacer()
            AppCard {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(
                        title: "Energy Day Map",
                        subtitle: "How is your energy today? We'll build Flow Blocks."
                    )
                    EnergyLevelPicker(selection: $selectedEnergy)
                    Text(selectedEnergy.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
        }
    }

    private var outcomeStep: some View {
        VStack(spacing: 20) {
            Spacer()
            AppCard {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(
                        title: "One Outcome",
                        subtitle: "Lock today's primary win — focus stays gated until this is set"
                    )
                    TextField("e.g. Finish proposal outline", text: $outcome)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("AppBackground").opacity(0.45))
                        )
                    HStack {
                        Text("Momentum starts at")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Spacer()
                        Text("0")
                            .font(.title.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Group {
                        if index == step {
                            Capsule().fill(AppGradients.primary)
                        } else {
                            Capsule().fill(Color("AppTextSecondary").opacity(0.25))
                        }
                    }
                    .frame(width: index == step ? 28 : 8, height: 8)
                }
            }

            AppPrimaryButton(
                step < totalSteps - 1 ? "Continue" : "Start Weekly Flow",
                icon: step < totalSteps - 1 ? "arrow.right" : "checkmark"
            ) {
                advance()
            }
            .disabled(!canAdvance)
            .opacity(canAdvance ? 1 : 0.5)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    private var canAdvance: Bool {
        switch step {
        case 0: return true
        case 1: return !intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2: return true
        case 3: return !outcome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return true
        }
    }

    private func advance() {
        FeedbackService.mediumAction()
        switch step {
        case 0:
            withAnimation { step = 1 }
        case 1:
            var plan = store.weeklyPlan
            plan.intention = intention.trimmingCharacters(in: .whitespacesAndNewlines)
            store.updateWeeklyPlan(plan)
            withAnimation { step = 2 }
        case 2:
            store.applyEnergyDayMap(selectedEnergy)
            withAnimation { step = 3 }
        case 3:
            store.setPrimaryOutcome(outcome)
            store.completeOnboarding()
        default:
            break
        }
    }
}
