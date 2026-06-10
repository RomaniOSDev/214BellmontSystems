import SwiftUI

struct HabitCalendarView: View {
    let habit: Habit
    @EnvironmentObject private var store: AppDataStore

    private let weeksToShow = 4
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(title: "Last \(weeksToShow) Weeks", subtitle: "Tap days show your consistency")

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                }

                ForEach(calendarDays, id: \.self) { date in
                    dayCell(for: date)
                }
            }
        }
    }

    private var weekdayHeaders: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }

    private var calendarDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = weeksToShow * 7
        guard let start = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today) else { return [] }

        return (0..<totalDays).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isCompleted = store.habitCompletedOnDate(habit, date: date)

        return ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(cellColor(isCompleted: isCompleted, isToday: isToday))
                .frame(height: 32)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color("AppTextPrimary"))
            } else if isToday {
                Circle()
                    .stroke(Color("AppPrimary"), lineWidth: 2)
                    .frame(width: 22, height: 22)
            }
        }
    }

    private func cellColor(isCompleted: Bool, isToday: Bool) -> Color {
        if isCompleted { return Color("AppPrimary") }
        if isToday { return Color("AppBackground").opacity(0.6) }
        return Color("AppBackground").opacity(0.35)
    }
}

struct HabitDetailSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let habitId: UUID

    private var habit: Habit? {
        store.habits.first { $0.id == habitId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    if let habit {
                        VStack(spacing: 16) {
                            AppCard {
                                HStack(spacing: 16) {
                                    AppIconCircle(icon: "leaf.fill", size: 52, iconColor: Color("AppAccent"))
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(habit.name)
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        HStack(spacing: 6) {
                                            Image(systemName: "flame.fill")
                                                .foregroundStyle(Color("AppPrimary"))
                                            Text("\(habit.streakCount) day streak")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color("AppAccent"))
                                        }
                                    }
                                    Spacer()
                                }
                            }

                            AppCard {
                                HabitCalendarView(habit: habit)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Habit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .appToolbarStyle()
        }
    }
}
