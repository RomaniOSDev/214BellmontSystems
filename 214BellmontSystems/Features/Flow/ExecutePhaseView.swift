import SwiftUI

struct ExecutePhaseView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager
    @Binding var selectedPhase: FlowPhase
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        MomentumHeroBanner(breakdown: store.momentumBreakdown)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        executeHeader
                        if !store.hasEnergyMapToday || !store.hasPrimaryOutcomeToday {
                            gateSection
                        }
                        OneOutcomeCard()
                            .padding(.horizontal, 16)
                        todaysBlocksSection
                        focusSection
                        anchorsSection
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Execute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .appToolbarStyle()
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        SettingsView()
                    }
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showSettings = false }
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appToolbarStyle()
                }
            }
            .onAppear {
                store.refreshDailyStateIfNeeded()
                achievementManager.evaluate(store: store)
            }
        }
    }

    private var executeHeader: some View {
        AppCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    if let map = store.energyDayMap, map.isToday {
                        HStack(spacing: 8) {
                            EnergyBadge(level: map.dayEnergy)
                            AppBadge(text: "Day Mapped", style: .accent)
                        }
                    }
                    if store.hasPrimaryOutcomeToday {
                        Text(store.dayOutcome?.primaryOutcome ?? "")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                    } else {
                        Text("Lock One Outcome to unlock deep work")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    HStack(spacing: 8) {
                        AppBadge(text: "\(Int(store.todaysFlowProgress * 100))% blocks", style: .neutral)
                        AppBadge(
                            text: "\(store.todaysFlowBlocks.filter(\.isCompleted).count)/\(max(store.todaysFlowBlocks.count, 1))",
                            style: .primary
                        )
                    }
                }

                Spacer()

                Button {
                    FeedbackService.lightTap()
                    selectedPhase = .plan
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                        Text("Plan")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var gateSection: some View {
        AppCard {
            HStack(alignment: .top, spacing: 12) {
                AppIconCircle(icon: "lock.fill", size: 40, iconColor: Color("AppAccent"))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Focus Gate")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(store.focusGateMessage)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if !store.hasEnergyMapToday {
                        Button("Open Energy Day Map") {
                            selectedPhase = .plan
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var todaysBlocksSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Flow Blocks", subtitle: "Energy-matched time blocks")

                if store.todaysFlowBlocks.isEmpty {
                    Text("Map your energy on Plan to auto-build today's blocks.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.todaysFlowBlocks) { block in
                        FlowBlockCell(block: block, onToggle: {
                            store.toggleFlowBlockCompletion(id: block.id)
                            achievementManager.evaluate(store: store)
                        }, onStartFocus: {
                            guard store.canStartFocus else {
                                FeedbackService.warning()
                                return
                            }
                            if let taskId = block.linkedTaskId {
                                store.selectedFocusTaskId = taskId
                            }
                        })
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var focusSection: some View {
        Group {
            if store.canStartFocus {
                FocusCycleView()
            } else {
                AppCard {
                    VStack(spacing: 12) {
                        AppIconCircle(icon: "timer", size: 48, iconColor: Color("AppTextSecondary"))
                        Text("Deep Work Locked")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(store.focusGateMessage)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var anchorsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "Anchors", subtitle: "Daily consistency check-ins")
                    Spacer()
                    NavigationLink {
                        DailyHabitLogView()
                    } label: {
                        Text("All")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }

                if store.habits.isEmpty {
                    Text("Add anchors to reinforce your weekly flow.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.habits.prefix(3)) { habit in
                        HabitCell(
                            habit: habit,
                            isHighlighted: false,
                            weekPreview: HabitCell.weekPreview(for: habit, store: store),
                            onTap: {
                                if store.checkInHabit(id: habit.id) {
                                    FeedbackService.success()
                                    achievementManager.evaluate(store: store)
                                } else {
                                    FeedbackService.lightTap()
                                }
                            },
                            onShowCalendar: {}
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
