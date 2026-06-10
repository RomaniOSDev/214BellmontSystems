import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager
    @Binding var selectedTab: AppTab

    @StateObject private var viewModel: HomeViewModel
    @State private var showWeeklyReview = false

    init(selectedTab: Binding<AppTab>, store: AppDataStore) {
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        statsGrid
                        featureWidgets
                        quickActions
                        todayTasksSection
                        weeklySnapshot
                    }
                    .padding(.vertical, 12)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .appToolbarStyle()
            .sheet(isPresented: $showWeeklyReview) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        WeeklyReviewView()
                    }
                    .navigationTitle("Weekly Review")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showWeeklyReview = false }
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appToolbarStyle()
                }
            }
        }
        .onAppear {
            store.refreshHabitsForToday()
            achievementManager.evaluate(store: store)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text("Dashboard")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(viewModel.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private var headerSection: some View {
        AppCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.greeting)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Ready to make today productive?")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))

                    HStack(spacing: 8) {
                        AppBadge(text: "\(viewModel.streakDays) day streak", style: .accent)
                        if viewModel.unlockedAchievements > 0 {
                            AppBadge(text: "\(viewModel.unlockedAchievements) badges", style: .primary)
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 0)

                Image("home_focus_widget")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("AppTextPrimary").opacity(0.2), Color("AppPrimary").opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
        }
        .padding(.horizontal, 16)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            HomeStatWidget(
                value: "\(viewModel.activeTasks)",
                label: "Active Tasks",
                icon: "checklist",
                accent: Color("AppPrimary")
            )
            HomeStatWidget(
                value: "\(viewModel.todayFocusMinutes)m",
                label: "Focus Today",
                icon: "timer",
                accent: Color("AppAccent")
            )
            HomeStatWidget(
                value: "\(viewModel.habitsDoneToday)/\(max(viewModel.habitsTotal, 1))",
                label: "Habits Done",
                icon: "leaf.fill",
                accent: Color("AppPrimary")
            )
            HomeStatWidget(
                value: "\(viewModel.dueTodayCount)",
                label: "Due Today",
                icon: "calendar",
                accent: Color("AppAccent")
            )
        }
        .padding(.horizontal, 16)
    }

    private var featureWidgets: some View {
        VStack(spacing: 12) {
            AppSectionHeader(title: "Your Tools", subtitle: "Tap a widget to jump in")
                .padding(.horizontal, 16)

            HomeFeatureWidget(
                title: "Task Organizer",
                subtitle: "Manage priorities and deadlines",
                imageName: "home_tasks_widget",
                metrics: [
                    ("\(viewModel.activeTasks)", "Active"),
                    ("\(viewModel.overdueCount)", "Overdue")
                ]
            ) {
                selectedTab = .tasks
            }
            .padding(.horizontal, 16)

            HomeFeatureWidget(
                title: "Focus Cycle",
                subtitle: "Deep work with Pomodoro timer",
                imageName: "home_focus_widget",
                metrics: [
                    ("\(viewModel.todayFocusMinutes)", "Min"),
                    ("\(viewModel.todayFocusSessions)", "Sessions")
                ]
            ) {
                selectedTab = .productivity
            }
            .padding(.horizontal, 16)

            HomeFeatureWidget(
                title: "Daily Habits",
                subtitle: "Build consistency day by day",
                imageName: "home_habits_widget",
                metrics: [
                    ("\(viewModel.habitsDoneToday)", "Done"),
                    ("\(store.longestStreak)", "Best")
                ]
            ) {
                selectedTab = .productivity
            }
            .padding(.horizontal, 16)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions")
                .padding(.horizontal, 16)

            HStack(spacing: 10) {
                HomeQuickAction(title: "Tasks", icon: "plus.circle.fill") {
                    selectedTab = .tasks
                }
                HomeQuickAction(title: "Focus", icon: "play.fill") {
                    selectedTab = .productivity
                }
                HomeQuickAction(title: "Stats", icon: "chart.bar.fill") {
                    selectedTab = .achievements
                }
                HomeQuickAction(title: "Settings", icon: "gearshape.fill") {
                    selectedTab = .settings
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var todayTasksSection: some View {
        let tasks = viewModel.upcomingTasks
        if !tasks.isEmpty {
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        AppSectionHeader(title: "Up Next", subtitle: "Your priority tasks")
                        Spacer()
                        Button {
                            FeedbackService.lightTap()
                            selectedTab = .tasks
                        } label: {
                            Text("See All")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }

                    ForEach(tasks) { task in
                        HomeTaskPreviewRow(task: task) {
                            let completed = store.toggleTaskCompletion(id: task.id)
                            if completed {
                                FeedbackService.taskCompleted()
                                achievementManager.evaluate(store: store)
                            } else {
                                FeedbackService.lightTap()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var weeklySnapshot: some View {
        let review = viewModel.weeklyReview

        return AppCardButton {
            showWeeklyReview = true
        } content: {
            HStack(spacing: 14) {
                AppIconCircle(icon: "chart.bar.xaxis", size: 44, iconColor: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Snapshot")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Tasks \(review.tasksCompleted) · Focus \(review.focusMinutes)m · Habits \(review.habitCheckIns)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
    }
}
