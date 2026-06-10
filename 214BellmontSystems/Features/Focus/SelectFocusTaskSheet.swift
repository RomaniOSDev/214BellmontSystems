import SwiftUI

struct SelectFocusTaskSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                if store.activeTasksForFocus.isEmpty {
                    AppEmptyState(
                        icon: "checklist",
                        title: "No active tasks",
                        message: "Add a task first to link focus sessions and track time per task."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            noTaskCell

                            ForEach(store.activeTasksForFocus) { task in
                                taskCell(task)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Link Task")
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

    private var noTaskCell: some View {
        AppCardButton {
            store.selectedFocusTaskId = nil
            dismiss()
        } content: {
            HStack {
                AppIconCircle(icon: "xmark", size: 40, iconColor: Color("AppTextSecondary"))
                Text("No task linked")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                if store.selectedFocusTaskId == nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private func taskCell(_ task: TaskItem) -> some View {
        AppCardButton {
            store.selectedFocusTaskId = task.id
            dismiss()
        } content: {
            HStack(spacing: 14) {
                AppIconCircle(icon: "link", size: 40, iconColor: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if store.focusMinutesForTask(task.id) > 0 {
                        Text("\(store.focusMinutesForTask(task.id)) min focused")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                Spacer()
                if store.selectedFocusTaskId == task.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
