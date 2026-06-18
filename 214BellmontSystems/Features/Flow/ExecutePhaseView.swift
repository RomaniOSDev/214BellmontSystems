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
                        executeHeader
                        todaysBlocksSection
                        FocusCycleView()
                        habitsQuickSection
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Execute Today")
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
        }
    }

    private var executeHeader: some View {
        AppCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    if !store.weeklyPlan.intention.isEmpty {
                        Text(store.weeklyPlan.intention)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    } else {
                        Text("No weekly intention set")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    HStack(spacing: 8) {
                        AppBadge(text: "\(Int(store.todaysFlowProgress * 100))% blocks done", style: .accent)
                        AppBadge(text: "\(store.todaysFlowBlocks.filter(\.isCompleted).count)/\(max(store.todaysFlowBlocks.count, 1))", style: .neutral)
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
        .padding(.top, 12)
    }

    @ViewBuilder
    private var todaysBlocksSection: some View {
        if !store.todaysFlowBlocks.isEmpty {
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Flow Blocks", subtitle: "Your time-blocked schedule")

                    ForEach(store.todaysFlowBlocks) { block in
                        FlowBlockCell(block: block, onToggle: {
                            store.toggleFlowBlockCompletion(id: block.id)
                        }, onStartFocus: {
                            if let taskId = block.linkedTaskId {
                                store.selectedFocusTaskId = taskId
                            }
                        })
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var habitsQuickSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "Daily Anchors", subtitle: "Quick habit check-ins")
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
                    Text("Add habits in the full habit log to reinforce your flow.")
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
