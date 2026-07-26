import SwiftUI

struct DailyHabitLogView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager
    @State private var showAddHabit = false
    @State private var editingHabit: Habit?
    @State private var detailHabit: Habit?
    @State private var highlightHabitID: UUID?

    private var completedToday: Int { store.habits.filter(\.completedToday).count }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if store.habits.isEmpty {
                ScrollView {
                    AppEmptyState(
                        icon: "calendar",
                        title: "No anchors yet",
                        message: "Add daily anchors to reinforce your Weekly Flow.",
                        actionTitle: "Add Anchor"
                    ) {
                        showAddHabit = true
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        habitsOverview
                        habitsList
                    }
                    .padding(.vertical, 12)
                    .padding(.bottom, 90)
                }
            }

            if !store.habits.isEmpty {
                AppFloatingButton(title: "Add Anchor", icon: "plus") {
                    showAddHabit = true
                }
                .padding(16)
            }
        }
        .onAppear { store.refreshHabitsForToday() }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView { name in
                store.addHabit(name: name)
                FeedbackService.success()
                achievementManager.evaluate(store: store)
            }
        }
        .sheet(item: $editingHabit) { habit in
            AddHabitView(existingHabit: habit) { name in
                var updated = habit
                updated.name = name
                store.updateHabit(updated)
                FeedbackService.success()
            }
        }
        .sheet(item: $detailHabit) { habit in
            HabitDetailSheet(habitId: habit.id)
        }
    }

    private var habitsOverview: some View {
        AppCard {
            HStack(spacing: 0) {
                AppMetricTile(
                    value: "\(store.habits.count)",
                    label: "Total Habits",
                    icon: "leaf.fill"
                )
                AppMetricTile(
                    value: "\(completedToday)",
                    label: "Done Today",
                    icon: "checkmark.circle.fill"
                )
                AppMetricTile(
                    value: "\(store.longestStreak)",
                    label: "Best Streak",
                    icon: "flame.fill"
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private var habitsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(store.habits) { habit in
                HabitCell(
                    habit: habit,
                    isHighlighted: highlightHabitID == habit.id,
                    weekPreview: HabitCell.weekPreview(for: habit, store: store),
                    onTap: { checkIn(habit) },
                    onShowCalendar: { detailHabit = habit }
                )
                .contextMenu {
                    Button { detailHabit = habit } label: {
                        Label("Calendar", systemImage: "calendar")
                    }
                    Button { editingHabit = habit } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        store.deleteHabit(id: habit.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func checkIn(_ habit: Habit) {
        let success = store.checkInHabit(id: habit.id)
        if success {
            FeedbackService.habitCheckIn()
            FeedbackService.success()
            highlightHabitID = habit.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { highlightHabitID = nil }
            achievementManager.evaluate(store: store)
        } else {
            FeedbackService.lightTap()
        }
    }
}
