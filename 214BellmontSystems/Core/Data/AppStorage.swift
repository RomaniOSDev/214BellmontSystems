import Combine
import Foundation

@MainActor
final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let tasks = "tasks"
        static let defaultCategory = "defaultCategory"
        static let habits = "habits"
        static let selectedDate = "selectedDate"
        static let notificationsEnabled = "notificationsEnabled"
        static let focusDurationMin = "focusDurationMin"
        static let breakDurationMin = "breakDurationMin"
        static let completedSessionsCount = "completedSessionsCount"
        static let tasksCompleted = "tasksCompleted"
        static let focusSessionsCompleted = "focusSessionsCompleted"
        static let habitCheckIns = "habitCheckIns"
        static let totalFocusMinutes = "totalFocusMinutes"
        static let longestStreak = "longestStreak"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let taskTemplates = "taskTemplates"
        static let focusSessionHistory = "focusSessionHistory"
        static let selectedFocusTaskId = "selectedFocusTaskId"
        static let templatesSeeded = "templatesSeeded"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var tasks: [TaskItem] {
        didSet { save(tasks, forKey: Keys.tasks) }
    }

    @Published var defaultCategory: String {
        didSet { defaults.set(defaultCategory, forKey: Keys.defaultCategory) }
    }

    @Published var habits: [Habit] {
        didSet { save(habits, forKey: Keys.habits) }
    }

    @Published var selectedDate: Date {
        didSet { defaults.set(selectedDate.timeIntervalSince1970, forKey: Keys.selectedDate) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }

    @Published var focusDurationMin: Int {
        didSet { defaults.set(focusDurationMin, forKey: Keys.focusDurationMin) }
    }

    @Published var breakDurationMin: Int {
        didSet { defaults.set(breakDurationMin, forKey: Keys.breakDurationMin) }
    }

    @Published var completedSessionsCount: Int {
        didSet { defaults.set(completedSessionsCount, forKey: Keys.completedSessionsCount) }
    }

    @Published var tasksCompleted: Int {
        didSet { defaults.set(tasksCompleted, forKey: Keys.tasksCompleted) }
    }

    @Published var focusSessionsCompleted: Int {
        didSet { defaults.set(focusSessionsCompleted, forKey: Keys.focusSessionsCompleted) }
    }

    @Published var habitCheckIns: Int {
        didSet { defaults.set(habitCheckIns, forKey: Keys.habitCheckIns) }
    }

    @Published var totalFocusMinutes: Int {
        didSet {
            defaults.set(totalFocusMinutes, forKey: Keys.totalFocusMinutes)
            totalMinutesUsed = totalFocusMinutes
        }
    }

    @Published var longestStreak: Int {
        didSet { defaults.set(longestStreak, forKey: Keys.longestStreak) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { save(achievementsUnlocked, forKey: Keys.achievementsUnlocked) }
    }

    @Published var taskTemplates: [TaskTemplate] {
        didSet { save(taskTemplates, forKey: Keys.taskTemplates) }
    }

    @Published var focusSessionHistory: [FocusSessionRecord] {
        didSet { save(focusSessionHistory, forKey: Keys.focusSessionHistory) }
    }

    @Published var selectedFocusTaskId: UUID? {
        didSet {
            if let id = selectedFocusTaskId {
                defaults.set(id.uuidString, forKey: Keys.selectedFocusTaskId)
            } else {
                defaults.removeObject(forKey: Keys.selectedFocusTaskId)
            }
        }
    }

    static let taskCategories = ["General", "Work", "Personal", "Health", "Learning"]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        tasks = Self.load([TaskItem].self, from: defaults, key: Keys.tasks) ?? []
        defaultCategory = defaults.string(forKey: Keys.defaultCategory) ?? "General"
        habits = Self.load([Habit].self, from: defaults, key: Keys.habits) ?? []
        let dateInterval = defaults.double(forKey: Keys.selectedDate)
        selectedDate = dateInterval > 0 ? Date(timeIntervalSince1970: dateInterval) : Date()
        notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        focusDurationMin = defaults.object(forKey: Keys.focusDurationMin) as? Int ?? 25
        breakDurationMin = defaults.object(forKey: Keys.breakDurationMin) as? Int ?? 5
        completedSessionsCount = defaults.integer(forKey: Keys.completedSessionsCount)
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionsCompleted)
        habitCheckIns = defaults.integer(forKey: Keys.habitCheckIns)
        totalFocusMinutes = defaults.integer(forKey: Keys.totalFocusMinutes)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        let lastInterval = defaults.double(forKey: Keys.lastActivityDate)
        lastActivityDate = lastInterval > 0 ? Date(timeIntervalSince1970: lastInterval) : nil
        achievementsUnlocked = Self.load([String: Date].self, from: defaults, key: Keys.achievementsUnlocked) ?? [:]
        taskTemplates = Self.load([TaskTemplate].self, from: defaults, key: Keys.taskTemplates) ?? []
        focusSessionHistory = Self.load([FocusSessionRecord].self, from: defaults, key: Keys.focusSessionHistory) ?? []
        if let taskIdString = defaults.string(forKey: Keys.selectedFocusTaskId) {
            selectedFocusTaskId = UUID(uuidString: taskIdString)
        } else {
            selectedFocusTaskId = nil
        }
        seedTemplatesIfNeeded()
        migrateHabitDatesIfNeeded()
        refreshHabitsForToday()
    }

    private func migrateHabitDatesIfNeeded() {
        var changed = false
        for index in habits.indices {
            if let last = habits[index].lastCompletedDate {
                let calendar = Calendar.current
                let hasDate = habits[index].completedDates.contains { calendar.isDate($0, inSameDayAs: last) }
                if !hasDate {
                    habits[index].completedDates.append(calendar.startOfDay(for: last))
                    changed = true
                }
            }
        }
        if changed {
            habits = habits
        }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    // MARK: - Tasks

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        recordActivity()
    }

    func addTaskFromTemplate(_ template: TaskTemplate) {
        let task = TaskItem(
            title: template.title,
            category: template.category,
            priority: template.priority
        )
        addTask(task)
    }

    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        if selectedFocusTaskId == id {
            selectedFocusTaskId = nil
        }
    }

    func toggleTaskCompletion(id: UUID) -> Bool {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return false }
        let wasCompleted = tasks[index].completed
        tasks[index].completed.toggle()
        if tasks[index].completed && !wasCompleted {
            tasks[index].completedAt = Date()
            tasksCompleted += 1
            recordActivity()
            return true
        } else if !tasks[index].completed && wasCompleted {
            tasks[index].completedAt = nil
        }
        return false
    }

    func toggleSubtask(taskId: UUID, subtaskId: UUID) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId }),
              let subIndex = tasks[taskIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else { return }
        tasks[taskIndex].subtasks[subIndex].completed.toggle()
    }

    func filteredAndSortedTasks(filter: TaskFilter, sort: TaskSort) -> [TaskItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var result = tasks

        switch filter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.completed }
        case .completed:
            result = result.filter(\.completed)
        case .dueToday:
            result = result.filter { $0.isDueToday }
        case .overdue:
            result = result.filter(\.isOverdue)
        }

        switch sort {
        case .priority:
            result.sort { $0.priority.sortOrder < $1.priority.sortOrder }
        case .dueDate:
            result.sort { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (l?, r?): return l < r
                case (nil, _?): return false
                case (_?, nil): return true
                case (nil, nil): return lhs.createdAt > rhs.createdAt
                }
            }
        case .category:
            result.sort { $0.category < $1.category }
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        }

        return result
    }

    // MARK: - Templates

    func addTemplate(_ template: TaskTemplate) {
        taskTemplates.append(template)
    }

    func deleteTemplate(id: UUID) {
        taskTemplates.removeAll { $0.id == id }
    }

    private func seedTemplatesIfNeeded() {
        guard !defaults.bool(forKey: Keys.templatesSeeded) else { return }
        if taskTemplates.isEmpty {
            taskTemplates = TaskTemplate.defaults
        }
        defaults.set(true, forKey: Keys.templatesSeeded)
    }

    // MARK: - Habits

    func addHabit(name: String) {
        habits.append(Habit(name: name))
        recordActivity()
    }

    func updateHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
    }

    @discardableResult
    func checkInHabit(id: UUID) -> Bool {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return false }
        guard !habits[index].completedToday else { return false }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = habits[index].lastCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                habits[index].streakCount += 1
            } else if dayDiff > 1 {
                habits[index].streakCount = 1
            }
        } else {
            habits[index].streakCount = 1
        }

        habits[index].completedToday = true
        habits[index].lastCompletedDate = today
        if !habits[index].completedDates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            habits[index].completedDates.append(today)
        }
        habitCheckIns += 1

        let maxStreak = habits.map(\.streakCount).max() ?? 0
        if maxStreak > longestStreak {
            longestStreak = maxStreak
        }

        recordActivity()
        return true
    }

    func refreshHabitsForToday() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var changed = false

        for index in habits.indices {
            if let lastDate = habits[index].lastCompletedDate {
                let lastDay = calendar.startOfDay(for: lastDate)
                if lastDay != today && habits[index].completedToday {
                    habits[index].completedToday = false
                    changed = true
                }
            } else if habits[index].completedToday {
                habits[index].completedToday = false
                changed = true
            }
        }

        if changed {
            habits = habits
        }
    }

    func habitCompletedOnDate(_ habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        return habit.completedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    // MARK: - Focus

    @discardableResult
    func recordFocusSessionCompleted(
        minutes: Int,
        sessionNumber: Int,
        note: String? = nil
    ) -> UUID {
        let linkedTask = selectedFocusTaskId.flatMap { id in tasks.first { $0.id == id } }
        let record = FocusSessionRecord(
            durationMinutes: minutes,
            sessionNumber: sessionNumber,
            linkedTaskId: linkedTask?.id,
            linkedTaskTitle: linkedTask?.title,
            note: note
        )
        focusSessionHistory.insert(record, at: 0)
        focusSessionsCompleted += 1
        totalSessionsCompleted += 1
        completedSessionsCount += 1
        totalFocusMinutes += minutes
        recordActivity()
        return record.id
    }

    func updateFocusSessionNote(id: UUID, note: String) {
        guard let index = focusSessionHistory.firstIndex(where: { $0.id == id }) else { return }
        focusSessionHistory[index].note = note.isEmpty ? nil : note
    }

    func focusMinutesForTask(_ taskId: UUID) -> Int {
        focusSessionHistory
            .filter { $0.linkedTaskId == taskId }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    var activeTasksForFocus: [TaskItem] {
        tasks.filter { !$0.completed }
    }

    var selectedFocusTask: TaskItem? {
        guard let id = selectedFocusTaskId else { return nil }
        return tasks.first { $0.id == id }
    }

    // MARK: - Weekly Review

    func weeklyReview() -> WeeklyReviewData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        let completedCount = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return completedAt >= weekStart
        }.count

        let weekSessions = focusSessionHistory.filter { $0.date >= weekStart }
        let focusMinutes = weekSessions.reduce(0) { $0 + $1.durationMinutes }

        let checkIns = habits.reduce(0) { total, habit in
            total + habit.completedDates.filter { $0 >= weekStart }.count
        }

        var dailyMinutes: [(date: Date, minutes: Int)] = []
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: day)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let minutes = weekSessions
                .filter { $0.date >= dayStart && $0.date < dayEnd }
                .reduce(0) { $0 + $1.durationMinutes }
            dailyMinutes.append((date: dayStart, minutes: minutes))
        }
        dailyMinutes.reverse()

        return WeeklyReviewData(
            tasksCompleted: completedCount,
            focusMinutes: focusMinutes,
            focusSessions: weekSessions.count,
            habitCheckIns: checkIns,
            dailyFocusMinutes: dailyMinutes
        )
    }

    // MARK: - Achievements

    func unlockAchievement(id: String) {
        achievementsUnlocked[id] = Date()
    }

    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = today
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier
        if let domain {
            defaults.removePersistentDomain(forName: domain)
        }
        defaults.synchronize()

        hasSeenOnboarding = false
        tasks = []
        defaultCategory = "General"
        habits = []
        selectedDate = Date()
        notificationsEnabled = false
        focusDurationMin = 25
        breakDurationMin = 5
        completedSessionsCount = 0
        tasksCompleted = 0
        focusSessionsCompleted = 0
        habitCheckIns = 0
        totalFocusMinutes = 0
        longestStreak = 0
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        taskTemplates = []
        focusSessionHistory = []
        selectedFocusTaskId = nil
        defaults.set(false, forKey: Keys.templatesSeeded)
        seedTemplatesIfNeeded()
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
