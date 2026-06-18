import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let taskId: UUID
    @State private var newSubtaskTitle = ""

    private var task: TaskItem? {
        store.tasks.first { $0.id == taskId }
    }

    private var weeklyPriorityBinding: Binding<Bool> {
        Binding(
            get: { task?.isWeeklyPriority ?? false },
            set: { newValue in
                let current = task?.isWeeklyPriority ?? false
                if newValue != current {
                    store.toggleWeeklyPriority(taskId: taskId)
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                if let task {
                    ScrollView {
                        VStack(spacing: 16) {
                            detailsCard(task)
                            subtasksCard(task)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(task?.title ?? "Task")
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

    private func detailsCard(_ task: TaskItem) -> some View {
        AppCard {
            VStack(spacing: 14) {
                HStack {
                    AppIconCircle(icon: "doc.text.fill", size: 44, iconColor: Color("AppPrimary"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        HStack(spacing: 6) {
                            AppBadge(text: task.category, style: .neutral)
                            AppBadge(text: task.priority.displayName, style: .accent)
                            EnergyBadge(level: task.energyLevel, compact: true)
                        }
                    }
                    Spacer()
                }

                Divider().background(Color("AppTextPrimary").opacity(0.1))

                Toggle(isOn: weeklyPriorityBinding) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color("AppPrimary"))
                        Text("Weekly Priority Outcome")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
                .tint(Color("AppPrimary"))

                detailRow(icon: "folder", label: "Category", value: task.category)
                detailRow(icon: "flag.fill", label: "Priority", value: task.priority.displayName)
                detailRow(icon: task.energyLevel.icon, label: "Energy", value: task.energyLevel.displayName)

                if let due = task.dueDate {
                    detailRow(icon: "calendar", label: "Due", value: due.formatted(date: .abbreviated, time: .omitted))
                }

                if store.focusMinutesForTask(task.id) > 0 {
                    detailRow(icon: "timer", label: "Focus Time", value: "\(store.focusMinutesForTask(task.id)) min")
                }
            }
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    private func subtasksCard(_ task: TaskItem) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    title: "Subtasks",
                    subtitle: task.subtasks.isEmpty ? "Break this task into steps" : task.subtasksProgress
                )

                if task.subtasks.isEmpty {
                    Text("No subtasks yet")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(task.subtasks) { subtask in
                        SubtaskCell(subtask: subtask) {
                            store.toggleSubtask(taskId: task.id, subtaskId: subtask.id)
                            FeedbackService.lightTap()
                        }
                    }
                }

                HStack(spacing: 10) {
                    TextField("Add subtask...", text: $newSubtaskTitle)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AppBackground").opacity(0.5))
                        )

                    Button { addSubtask(to: task) } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addSubtask(to task: TaskItem) {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = task
        updated.subtasks.append(Subtask(title: trimmed))
        store.updateTask(updated)
        newSubtaskTitle = ""
        FeedbackService.success()
    }
}
