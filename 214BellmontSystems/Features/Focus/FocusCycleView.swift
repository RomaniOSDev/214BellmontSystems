import SwiftUI

struct FocusCycleView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager

    var body: some View {
        FocusCycleViewContent(store: store, achievementManager: achievementManager)
    }
}

private struct FocusCycleViewContent: View {
    @ObservedObject private var store: AppDataStore
    @ObservedObject private var achievementManager: AchievementManager
    @StateObject private var viewModel: FocusCycleViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showCustomize = false
    @State private var showHistory = false

    init(store: AppDataStore, achievementManager: AchievementManager) {
        self.store = store
        self.achievementManager = achievementManager
        _viewModel = StateObject(wrappedValue: FocusCycleViewModel(store: store, achievementManager: achievementManager))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                sessionBadge
                timerCircle
                linkedTaskCard
                controlButtons
                upcomingCard
                quickActions
            }
            .padding(.vertical, 12)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showCustomize) { CustomizeCyclesView() }
        .sheet(isPresented: $viewModel.showTaskPicker) { SelectFocusTaskSheet() }
        .sheet(isPresented: $viewModel.showSessionNoteSheet) {
            FocusSessionNoteSheet { note in
                viewModel.saveSessionNote(note)
                viewModel.showSessionNoteSheet = false
            }
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                ZStack {
                    AppBackgroundView()
                    FocusSessionHistoryView()
                }
                .navigationTitle("Session History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showHistory = false }
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
                .appToolbarStyle()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            DispatchQueue.main.async {
                viewModel.handleScenePhase(newPhase)
            }
        }
    }

    @ViewBuilder
    private var sessionBadge: some View {
        if viewModel.phase != .idle || store.focusSessionsCompleted > 0 {
            AppBadge(text: viewModel.sessionLabel, style: .neutral)
        }
    }

    private var linkedTaskCard: some View {
        FocusLinkedTaskCell(
            taskTitle: viewModel.linkedTaskLabel,
            focusMinutes: store.selectedFocusTask.map { store.focusMinutesForTask($0.id) }
        ) {
            viewModel.showTaskPicker = true
        }
        .padding(.horizontal, 16)
    }

    private var timerCircle: some View {
        let progress = viewModel.progress()

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppSurface"), Color("AppBackground").opacity(0.6)],
                        center: .center,
                        startRadius: 40,
                        endRadius: 140
                    )
                )
                .frame(width: 260, height: 260)
                .overlay(Circle().stroke(Color("AppTextPrimary").opacity(0.06), lineWidth: 1))

            Circle()
                .stroke(Color("AppBackground").opacity(0.5), lineWidth: 16)
                .frame(width: 250, height: 250)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            timerContent
        }
        .compositingGroup()
        .frame(height: 270)
        .onLongPressGesture(minimumDuration: 0.5) { showCustomize = true }
    }

    @ViewBuilder
    private var timerContent: some View {
        if viewModel.phase == .idle && store.focusSessionsCompleted == 0 {
            VStack(spacing: 12) {
                AppIconCircle(icon: "clock.fill", size: 64, iconColor: Color("AppAccent"))
                Text("Start your first focus cycle!")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        } else if viewModel.phase == .idle && !viewModel.isRunning && viewModel.remainingSeconds == 0 {
            Text("Press start to begin")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
        } else {
            VStack(spacing: 6) {
                AppBadge(text: viewModel.phaseLabel, style: viewModel.phase == .focus ? .primary : .accent)
                Text(viewModel.formattedTime())
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .monospacedDigit()
            }
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 12) {
            AppPrimaryButton(viewModel.isRunning ? "Pause" : "Start", icon: viewModel.isRunning ? "pause.fill" : "play.fill") {
                if viewModel.isRunning { viewModel.pause() } else { viewModel.start() }
            }
            AppSecondaryButton("Reset", icon: "arrow.counterclockwise") {
                viewModel.reset()
            }
        }
        .padding(.horizontal, 16)
    }

    private var upcomingCard: some View {
        AppCard {
            HStack(spacing: 12) {
                AppIconCircle(icon: "forward.fill", size: 36, iconColor: Color("AppAccent"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Up Next")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(viewModel.upcomingCardText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            AppSecondaryButton("Customize", icon: "slider.horizontal.3") { showCustomize = true }
            AppSecondaryButton("History", icon: "clock.arrow.circlepath") { showHistory = true }
        }
        .padding(.horizontal, 16)
    }
}
