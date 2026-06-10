import SwiftUI

struct TaskOrganizerView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievementManager: AchievementManager
    @State private var showAddTask = false
    @State private var editingTask: TaskItem?
    @State private var detailTask: TaskItem?
    @State private var showTaskSettings = false
    @State private var showTemplates = false
    @State private var pulsingTaskID: UUID?
    @State private var taskFilter: TaskFilter = .all
    @State private var taskSort: TaskSort = .priority

    private var displayedTasks: [TaskItem] {
        store.filteredAndSortedTasks(filter: taskFilter, sort: taskSort)
    }

    private var activeCount: Int { store.tasks.filter { !$0.completed }.count }
    private var dueTodayCount: Int { store.tasks.filter(\.isDueToday).count }
    private var overdueCount: Int { store.tasks.filter(\.isOverdue).count }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                if store.tasks.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            statsOverview
                            filterBar
                            taskListContent
                        }
                        .padding(.vertical, 12)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Task Organizer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button { showTemplates = true } label: {
                            Label("Templates", systemImage: "doc.on.doc")
                        }
                        Button { showTaskSettings = true } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddTask = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color("AppPrimary"))
                            .font(.title3)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .appToolbarStyle()
            .safeAreaInset(edge: .bottom) {
                if !store.tasks.isEmpty {
                    bottomBar
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(defaultCategory: store.defaultCategory) { task in
                    store.addTask(task)
                    FeedbackService.success()
                    achievementManager.evaluate(store: store)
                }
            }
            .sheet(item: $editingTask) { task in
                AddTaskView(defaultCategory: store.defaultCategory, existingTask: task) { updated in
                    store.updateTask(updated)
                    FeedbackService.success()
                }
            }
            .sheet(isPresented: $showTaskSettings) { TaskSettingsSheet() }
            .sheet(isPresented: $showTemplates) { TaskTemplatesView() }
            .sheet(item: $detailTask) { task in
                TaskDetailView(taskId: task.id)
            }
        }
    }

    private var statsOverview: some View {
        AppCard {
            HStack(spacing: 0) {
                AppMetricTile(value: "\(activeCount)", label: "Active", icon: "checklist")
                AppMetricTile(value: "\(dueTodayCount)", label: "Due Today", icon: "calendar")
                AppMetricTile(value: "\(overdueCount)", label: "Overdue", icon: "exclamationmark.circle")
            }
        }
        .padding(.horizontal, 16)
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Filter & Sort")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TaskFilter.allCases) { filter in
                        AppChip(filter.displayName, icon: filterIcon(filter), isSelected: taskFilter == filter) {
                            taskFilter = filter
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TaskSort.allCases) { sort in
                        AppChip(sort.displayName, icon: "arrow.up.arrow.down", isSelected: taskSort == sort) {
                            taskSort = sort
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func filterIcon(_ filter: TaskFilter) -> String {
        switch filter {
        case .all: return "tray.full"
        case .active: return "circle"
        case .completed: return "checkmark.circle"
        case .dueToday: return "calendar"
        case .overdue: return "exclamationmark.triangle"
        }
    }

    @ViewBuilder
    private var taskListContent: some View {
        if displayedTasks.isEmpty {
            AppEmptyState(
                icon: "line.3.horizontal.decrease.circle",
                title: "No matches",
                message: "No tasks match the current filter. Try a different filter."
            )
        } else {
            LazyVStack(spacing: 10) {
                ForEach(displayedTasks) { task in
                    TaskCell(
                        task: task,
                        focusMinutes: store.focusMinutesForTask(task.id),
                        isPulsing: pulsingTaskID == task.id,
                        onToggle: { toggleTask(task) },
                        onOpen: { detailTask = task }
                    )
                    .contextMenu {
                        Button { editingTask = task } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            store.deleteTask(id: task.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var emptyState: some View {
        ScrollView {
            AppEmptyState(
                icon: "square.and.pencil",
                title: "No tasks yet",
                message: "Start by adding your first task or use a template to get going quickly.",
                actionTitle: "Browse Templates"
            ) {
                showTemplates = true
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color("AppTextPrimary").opacity(0.1))
            AppPrimaryButton("Add Task", icon: "plus") {
                showAddTask = true
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                AppGradients.surfaceElevated
                    .opacity(0.97)
            )
        }
    }

    private func toggleTask(_ task: TaskItem) {
        let completed = store.toggleTaskCompletion(id: task.id)
        if completed {
            FeedbackService.taskCompleted()
            pulsingTaskID = task.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { pulsingTaskID = nil }
            achievementManager.evaluate(store: store)
        } else {
            FeedbackService.lightTap()
        }
    }
}

private struct TaskSettingsSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        Picker("Default Category", selection: $store.defaultCategory) {
                            ForEach(AppDataStore.taskCategories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .appFormStyle()
            }
            .navigationTitle("Task Settings")
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
