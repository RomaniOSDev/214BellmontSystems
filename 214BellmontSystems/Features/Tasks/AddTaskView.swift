import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let defaultCategory: String
    let existingTask: TaskItem?
    let onSave: (TaskItem) -> Void

    @State private var title = ""
    @State private var category: String
    @State private var priority: TaskPriority = .medium
    @State private var energyLevel: EnergyLevel = .steady
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var errorMessage = ""
    @State private var shakeTrigger = 0

    init(
        defaultCategory: String,
        existingTask: TaskItem? = nil,
        onSave: @escaping (TaskItem) -> Void
    ) {
        self.defaultCategory = defaultCategory
        self.existingTask = existingTask
        self.onSave = onSave
        _category = State(initialValue: existingTask?.category ?? defaultCategory)
        _title = State(initialValue: existingTask?.title ?? "")
        _priority = State(initialValue: existingTask?.priority ?? .medium)
        _energyLevel = State(initialValue: existingTask?.energyLevel ?? .steady)
        _hasDueDate = State(initialValue: existingTask?.dueDate != nil)
        _dueDate = State(initialValue: existingTask?.dueDate ?? Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                Form {
                    Section {
                        TextField("Task title", text: $title)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Picker("Category", selection: $category) {
                            ForEach(AppDataStore.taskCategories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }

                        Picker("Priority", selection: $priority) {
                            ForEach(TaskPriority.allCases) { p in
                                Text(p.displayName).tag(p)
                            }
                        }
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Energy Level")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            EnergyLevelPicker(selection: $energyLevel)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section {
                        Toggle("Set Due Date", isOn: $hasDueDate)
                            .foregroundStyle(Color("AppTextPrimary"))

                        if hasDueDate {
                            DatePicker(
                                "Due Date",
                                selection: $dueDate,
                                displayedComponents: .date
                            )
                            .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTask == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func saveTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a task title"
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        FeedbackService.mediumAction()

        if var existing = existingTask {
            existing.title = trimmed
            existing.category = category
            existing.priority = priority
            existing.energyLevel = energyLevel
            existing.dueDate = hasDueDate ? dueDate : nil
            onSave(existing)
        } else {
            let task = TaskItem(
                title: trimmed,
                category: category,
                priority: priority,
                energyLevel: energyLevel,
                dueDate: hasDueDate ? dueDate : nil
            )
            onSave(task)
        }
        dismiss()
    }
}
