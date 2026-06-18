import SwiftUI

struct PlanPhaseView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var intentionText = ""
    @State private var outcome1 = ""
    @State private var outcome2 = ""
    @State private var outcome3 = ""
    @State private var showTaskOrganizer = false
    @State private var showSettings = false
    @State private var showAddBlock = false
    @State private var newBlockTitle = ""
    @State private var newBlockHour = 9
    @State private var newBlockDuration = 45
    @State private var newBlockEnergy: EnergyLevel = .steady

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        flowHeader
                        weeklyIntentionCard
                        priorityOutcomesCard
                        guidedRoutinesSection
                        flowBlocksPreview
                    }
                    .padding(.vertical, 12)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Plan Your Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                        Button {
                            showTaskOrganizer = true
                        } label: {
                            Image(systemName: "checklist")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                }
            }
            .appToolbarStyle()
            .sheet(isPresented: $showTaskOrganizer) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        TaskOrganizerView()
                    }
                    .navigationTitle("Task Library")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showTaskOrganizer = false }
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appToolbarStyle()
                }
            }
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
            .alert("Add Flow Block", isPresented: $showAddBlock) {
                TextField("Block title", text: $newBlockTitle)
                Button("Cancel", role: .cancel) { newBlockTitle = "" }
                Button("Add") { addCustomBlock() }
            } message: {
                Text("Schedule a time block for today.")
            }
            .onAppear {
                loadPlanFields()
                store.refreshWeeklyPlanIfNeeded()
            }
        }
    }

    private var flowHeader: some View {
        AppCard {
            HStack(spacing: 14) {
                AppIconCircle(icon: "calendar.badge.clock", size: 48, iconColor: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Flow")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Plan → Execute → Review")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                    Text("Design your week around energy, not just tasks.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var weeklyIntentionCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Weekly Intention", subtitle: "One sentence that guides your week")

                TextField("e.g. Ship the client proposal by Thursday", text: $intentionText, axis: .vertical)
                    .lineLimit(2...4)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color("AppBackground").opacity(0.45))
                    )
                    .onChange(of: intentionText) { _ in savePlan() }

                HStack {
                    Text("Focus goal")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Text("\(store.weeklyPlan.plannedFocusMinutes) min")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                }

                Slider(
                    value: Binding(
                        get: { Double(store.weeklyPlan.plannedFocusMinutes) },
                        set: {
                            var plan = store.weeklyPlan
                            plan.plannedFocusMinutes = Int($0)
                            store.updateWeeklyPlan(plan)
                        }
                    ),
                    in: 60...600,
                    step: 30
                )
                .tint(Color("AppPrimary"))
            }
        }
        .padding(.horizontal, 16)
    }

    private var priorityOutcomesCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Top 3 Outcomes", subtitle: "Pick from tasks or type outcomes")

                outcomeField($outcome1, placeholder: "Outcome 1")
                outcomeField($outcome2, placeholder: "Outcome 2")
                outcomeField($outcome3, placeholder: "Outcome 3")

                if !store.weeklyPriorityTasks.isEmpty {
                    Divider().background(Color("AppTextPrimary").opacity(0.1))
                    Text("Marked as weekly priority")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    ForEach(store.weeklyPriorityTasks) { task in
                        HStack {
                            EnergyBadge(level: task.energyLevel, compact: true)
                            Text(task.title)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func outcomeField(_ text: Binding<String>, placeholder: String) -> some View {
        TextField(placeholder, text: text)
            .font(.subheadline)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("AppBackground").opacity(0.4))
            )
            .onChange(of: text.wrappedValue) { _ in savePlan() }
    }

    private var guidedRoutinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Guided Routines", subtitle: "Pre-built flows for solo knowledge work")
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GuidedRoutine.all) { routine in
                        GuidedRoutineCard(routine: routine) {
                            store.applyGuidedRoutine(routine)
                        }
                        .frame(width: 260)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var flowBlocksPreview: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "Today's Flow Blocks", subtitle: "Time-blocked execution plan")
                    Spacer()
                    Button {
                        showAddBlock = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }

                if store.todaysFlowBlocks.isEmpty {
                    Text("Apply a guided routine or add a custom block to build your day.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.todaysFlowBlocks) { block in
                        FlowBlockCell(block: block) {
                            store.toggleFlowBlockCompletion(id: block.id)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func loadPlanFields() {
        intentionText = store.weeklyPlan.intention
        let outcomes = store.weeklyPlan.priorityOutcomes
        outcome1 = outcomes.indices.contains(0) ? outcomes[0] : ""
        outcome2 = outcomes.indices.contains(1) ? outcomes[1] : ""
        outcome3 = outcomes.indices.contains(2) ? outcomes[2] : ""
    }

    private func savePlan() {
        var outcomes: [String] = [outcome1, outcome2, outcome3]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        var plan = store.weeklyPlan
        plan.intention = intentionText.trimmingCharacters(in: .whitespacesAndNewlines)
        plan.priorityOutcomes = outcomes
        store.updateWeeklyPlan(plan)
    }

    private func addCustomBlock() {
        let title = newBlockTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        store.addFlowBlock(FlowBlock(
            title: title,
            startHour: newBlockHour,
            durationMinutes: newBlockDuration,
            energyLevel: newBlockEnergy
        ))
        newBlockTitle = ""
    }
}
