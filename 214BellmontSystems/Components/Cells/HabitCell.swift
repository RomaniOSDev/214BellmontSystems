import SwiftUI

struct HabitCell: View {
    let habit: Habit
    let isHighlighted: Bool
    let weekPreview: [Bool]
    let onTap: () -> Void
    let onShowCalendar: () -> Void

    private var progress: Double {
        min(Double(habit.streakCount) / 7.0, 1.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                checkInArea
                calendarButton
            }
            .padding(16)

            weekStrip
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
        }
        .background(
            ZStack {
                AppSurfaceShape(cornerRadius: 16)
                if isHighlighted {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("AppAccent").opacity(0.18))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    habit.completedToday
                        ? LinearGradient(colors: [Color("AppAccent"), Color("AppPrimary")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color("AppTextPrimary").opacity(0.1), Color("AppTextPrimary").opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: habit.completedToday ? 1.5 : 1
                )
        )
        .animation(.easeInOut(duration: 0.35), value: isHighlighted)
    }

    private var checkInArea: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(habit.completedToday ? Color("AppAccent").opacity(0.25) : Color("AppBackground").opacity(0.5))
                        .frame(width: 48, height: 48)
                    Image(systemName: habit.completedToday ? "checkmark.circle.fill" : "leaf.fill")
                        .font(.title3)
                        .foregroundStyle(habit.completedToday ? Color("AppAccent") : Color("AppPrimary"))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(Color("AppPrimary"))
                        Text("\(habit.streakCount) day streak")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    progressBar
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("AppBackground").opacity(0.5))
                    .frame(height: 6)
                Capsule()
                    .fill(AppGradients.progress)
                    .frame(width: geo.size.width * progress, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
            }
        }
        .frame(height: 6)
    }

    private var weekStrip: some View {
        HStack(spacing: 4) {
            ForEach(Array(weekPreview.enumerated()), id: \.offset) { _, done in
                Group {
                    if done {
                        RoundedRectangle(cornerRadius: 3).fill(AppGradients.primary)
                    } else {
                        RoundedRectangle(cornerRadius: 3).fill(Color("AppBackground").opacity(0.5))
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private var calendarButton: some View {
        Button(action: onShowCalendar) {
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.body.weight(.semibold))
                Text("View")
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(Color("AppPrimary"))
            .frame(width: 52, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppGradients.iconFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

}

extension HabitCell {
    static func weekPreview(for habit: Habit, store: AppDataStore) -> [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return false }
            return store.habitCompletedOnDate(habit, date: date)
        }
    }
}
