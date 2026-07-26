import SwiftUI

struct EnergyDayMapCard: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedEnergy: EnergyLevel = .steady

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    AppSectionHeader(
                        title: "Energy Day Map",
                        subtitle: store.hasEnergyMapToday
                            ? "Today mapped as \(store.energyDayMap?.dayEnergy.displayName ?? "")"
                            : "Choose morning energy — blocks auto-fill"
                    )
                    Spacer()
                    if store.hasEnergyMapToday, let map = store.energyDayMap {
                        EnergyBadge(level: map.dayEnergy)
                    }
                }

                if !store.hasEnergyMapToday {
                    EnergyLevelPicker(selection: $selectedEnergy)

                    Text(selectedEnergy.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))

                    AppPrimaryButton("Map Today & Build Blocks", icon: "bolt.fill") {
                        store.applyEnergyDayMap(selectedEnergy)
                        FeedbackService.success()
                    }
                } else {
                    Text("Peak tasks cannot be placed in Low slots. Remap to regenerate blocks.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))

                    AppSecondaryButton("Remap Energy", icon: "arrow.triangle.2.circlepath") {
                        store.applyEnergyDayMap(selectedEnergy)
                        FeedbackService.mediumAction()
                    }

                    EnergyLevelPicker(selection: $selectedEnergy)
                }
            }
        }
    }
}

struct OneOutcomeCard: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var draft = ""

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    title: "One Outcome",
                    subtitle: "Only one primary win for today — focus stays locked until set"
                )

                if store.hasPrimaryOutcomeToday, let outcome = store.dayOutcome {
                    HStack(spacing: 12) {
                        Button {
                            store.togglePrimaryOutcomeCompleted()
                            FeedbackService.lightTap()
                        } label: {
                            Image(systemName: outcome.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(outcome.isCompleted ? Color("AppAccent") : Color("AppTextSecondary"))
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(outcome.primaryOutcome)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .strikethrough(outcome.isCompleted)
                            AppBadge(text: "Primary", style: .primary)
                        }
                    }
                } else {
                    TextField("e.g. Ship proposal draft to client", text: $draft)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("AppBackground").opacity(0.45))
                        )

                    AppPrimaryButton("Lock Outcome", icon: "target") {
                        store.setPrimaryOutcome(draft)
                        draft = ""
                        FeedbackService.success()
                    }
                }
            }
        }
        .onAppear {
            draft = store.dayOutcome?.primaryOutcome ?? ""
        }
    }
}

struct WeeklyCommitmentCard: View {
    @EnvironmentObject private var store: AppDataStore

    private var status: CommitmentStatus { store.commitmentStatus }
    private var review: WeeklyReviewData { store.weeklyReview() }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    AppSectionHeader(
                        title: "Weekly Commitment",
                        subtitle: store.weeklyPlan.commitmentLocked
                            ? "Locked target for this week"
                            : "Commit focus minutes + outcomes"
                    )
                    Spacer()
                    Image(systemName: status.icon)
                        .foregroundStyle(status == .kept ? Color("AppAccent") : Color("AppPrimary"))
                }

                if store.weeklyPlan.commitmentLocked {
                    AppBadge(text: status.displayName, style: status == .kept ? .accent : (status == .missed ? .danger : .neutral))

                    let target = store.weeklyPlan.committedFocusMinutes ?? store.weeklyPlan.plannedFocusMinutes
                    AppMetricRow(metrics: [
                        ("\(review.focusMinutes)/\(target)", "Focus min"),
                        ("\(store.weeklyPlan.priorityOutcomes.filter { !$0.isEmpty }.count)", "Outcomes"),
                        ("\(store.momentumBreakdown.total)", "Momentum")
                    ])

                    Text(store.weeklyPlan.intention)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                } else {
                    Text("Lock your intention, top outcomes, and focus goal as this week's commitment.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))

                    AppPrimaryButton("Commit This Week", icon: "checkmark.seal.fill") {
                        store.lockWeeklyCommitment()
                        FeedbackService.success()
                    }
                    .disabled(
                        store.weeklyPlan.intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || store.weeklyPlan.priorityOutcomes.filter { !$0.isEmpty }.isEmpty
                    )
                    .opacity(
                        store.weeklyPlan.intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || store.weeklyPlan.priorityOutcomes.filter { !$0.isEmpty }.isEmpty
                            ? 0.5 : 1
                    )
                }
            }
        }
    }
}

struct MomentumHeroBanner: View {
    let breakdown: MomentumBreakdown

    var body: some View {
        AppCard(elevation: .high) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Momentum Score")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("\(breakdown.total)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppPrimary"))
                    HStack(spacing: 6) {
                        Image(systemName: breakdown.level.icon)
                        Text(breakdown.level.displayName)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color("AppAccent"))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color("AppBackground").opacity(0.5), lineWidth: 10)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: CGFloat(breakdown.total) / 100)
                        .stroke(AppGradients.progress, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }
}
