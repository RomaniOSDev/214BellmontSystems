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
        static let weeklyPlan = "weeklyPlan"
        static let flowBlocks = "flowBlocks"
        static let nicheTemplatesSeeded = "nicheTemplatesSeeded"
        static let energyDayMap = "energyDayMap"
        static let dayOutcome = "dayOutcome"
        static let energyMapsCompleted = "energyMapsCompleted"
        static let outcomesLocked = "outcomesLocked"
        static let peakBlocksCompleted = "peakBlocksCompleted"
        static let highestMomentum = "highestMomentum"
        static let commitmentsKept = "commitmentsKept"
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

    @Published var weeklyPlan: WeeklyPlan {
        didSet { save(weeklyPlan, forKey: Keys.weeklyPlan) }
    }

    @Published var flowBlocks: [FlowBlock] {
        didSet { save(flowBlocks, forKey: Keys.flowBlocks) }
    }

    @Published var energyDayMap: EnergyDayMap? {
        didSet { saveOptional(energyDayMap, forKey: Keys.energyDayMap) }
    }

    @Published var dayOutcome: DayOutcome? {
        didSet { saveOptional(dayOutcome, forKey: Keys.dayOutcome) }
    }

    @Published var energyMapsCompleted: Int {
        didSet { defaults.set(energyMapsCompleted, forKey: Keys.energyMapsCompleted) }
    }

    @Published var outcomesLocked: Int {
        didSet { defaults.set(outcomesLocked, forKey: Keys.outcomesLocked) }
    }

    @Published var peakBlocksCompleted: Int {
        didSet { defaults.set(peakBlocksCompleted, forKey: Keys.peakBlocksCompleted) }
    }

    @Published var highestMomentum: Int {
        didSet { defaults.set(highestMomentum, forKey: Keys.highestMomentum) }
    }

    @Published var commitmentsKept: Int {
        didSet { defaults.set(commitmentsKept, forKey: Keys.commitmentsKept) }
    }

    static let taskCategories = ["Outcomes", "Deep Work", "Delivery", "Admin", "Learning"]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        tasks = Self.load([TaskItem].self, from: defaults, key: Keys.tasks) ?? []
        defaultCategory = defaults.string(forKey: Keys.defaultCategory) ?? "Outcomes"
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
        weeklyPlan = Self.load(WeeklyPlan.self, from: defaults, key: Keys.weeklyPlan)
            ?? WeeklyPlan()
        flowBlocks = Self.load([FlowBlock].self, from: defaults, key: Keys.flowBlocks) ?? []
        energyDayMap = Self.load(EnergyDayMap.self, from: defaults, key: Keys.energyDayMap)
        dayOutcome = Self.load(DayOutcome.self, from: defaults, key: Keys.dayOutcome)
        energyMapsCompleted = defaults.integer(forKey: Keys.energyMapsCompleted)
        outcomesLocked = defaults.integer(forKey: Keys.outcomesLocked)
        peakBlocksCompleted = defaults.integer(forKey: Keys.peakBlocksCompleted)
        highestMomentum = defaults.integer(forKey: Keys.highestMomentum)
        commitmentsKept = defaults.integer(forKey: Keys.commitmentsKept)
        seedTemplatesIfNeeded()
        migrateNicheTemplatesIfNeeded()
        migrateHabitDatesIfNeeded()
        refreshHabitsForToday()
        refreshDailyStateIfNeeded()
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
            priority: template.priority,
            energyLevel: template.energyLevel
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

    private func migrateNicheTemplatesIfNeeded() {
        guard !defaults.bool(forKey: Keys.nicheTemplatesSeeded) else { return }
        taskTemplates = TaskTemplate.defaults
        defaults.set(true, forKey: Keys.nicheTemplatesSeeded)
    }

    // MARK: - Weekly Flow Plan

    func refreshWeeklyPlanIfNeeded() {
        if !weeklyPlan.isCurrentWeek {
            weeklyPlan = WeeklyPlan(
                intention: "",
                priorityOutcomes: [],
                plannedFocusMinutes: weeklyPlan.plannedFocusMinutes
            )
        }
    }

    func refreshDailyStateIfNeeded() {
        if let map = energyDayMap, !map.isToday {
            energyDayMap = nil
        }
        if let outcome = dayOutcome, !outcome.isToday {
            dayOutcome = nil
        }
    }

    func updateWeeklyPlan(_ plan: WeeklyPlan) {
        weeklyPlan = plan
        recordActivity()
        bumpHighestMomentum()
    }

    func lockWeeklyCommitment() {
        var plan = weeklyPlan
        let outcomes = plan.priorityOutcomes
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !plan.intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !outcomes.isEmpty else { return }
        plan.priorityOutcomes = Array(outcomes.prefix(3))
        plan.committedFocusMinutes = plan.plannedFocusMinutes
        plan.commitmentLocked = true
        plan.commitmentLockedAt = Date()
        weeklyPlan = plan
        recordActivity()
        bumpHighestMomentum()
    }

    var commitmentStatus: CommitmentStatus {
        guard weeklyPlan.commitmentLocked else { return .notCommitted }
        let review = weeklyReview()
        let target = weeklyPlan.committedFocusMinutes ?? weeklyPlan.plannedFocusMinutes
        let outcomesTarget = max(weeklyPlan.priorityOutcomes.filter { !$0.isEmpty }.count, 1)
        let completedPriorities = tasks.filter { $0.isWeeklyPriority && $0.completed }.count
        let outcomeProgress = max(completedPriorities, min(review.tasksCompleted, outcomesTarget))

        let focusMet = review.focusMinutes >= target
        let outcomesMet = outcomeProgress >= min(outcomesTarget, 1)

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let isWeekendReview = weekday == 1 || weekday == 7

        if focusMet && (outcomesMet || review.tasksCompleted >= 1) {
            return .kept
        }
        if isWeekendReview {
            return .missed
        }
        return .inProgress
    }

    func markCommitmentKeptIfNeeded() {
        if commitmentStatus == .kept, commitmentsKept == 0 || weeklyPlan.commitmentLocked {
            // Count once per locked week via highest watermark check
            let key = "commitmentCounted_\(Int(weeklyPlan.weekStart.timeIntervalSince1970))"
            if !defaults.bool(forKey: key) {
                commitmentsKept += 1
                defaults.set(true, forKey: key)
            }
        }
    }

    func toggleWeeklyPriority(taskId: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        let priorityCount = tasks.filter(\.isWeeklyPriority).count
        if !tasks[index].isWeeklyPriority && priorityCount >= 3 { return }
        tasks[index].isWeeklyPriority.toggle()
    }

    var weeklyPriorityTasks: [TaskItem] {
        tasks.filter { $0.isWeeklyPriority && !$0.completed }
    }

    // MARK: - Energy Day Map

    var hasEnergyMapToday: Bool {
        energyDayMap?.isToday == true
    }

    var hasPrimaryOutcomeToday: Bool {
        dayOutcome?.isToday == true && dayOutcome?.isSet == true
    }

    /// Focus timer requires Energy Day Map + One Outcome.
    var canStartFocus: Bool {
        hasEnergyMapToday && hasPrimaryOutcomeToday
    }

    var focusGateMessage: String {
        if !hasEnergyMapToday && !hasPrimaryOutcomeToday {
            return "Set your Energy Day Map and One Outcome before starting focus."
        }
        if !hasEnergyMapToday {
            return "Complete your Energy Day Map to unlock focus."
        }
        return "Lock One Outcome for today to unlock focus."
    }

    func applyEnergyDayMap(_ energy: EnergyLevel, replaceBlocks: Bool = true) {
        let map = EnergyDayMap(dayEnergy: energy)
        energyDayMap = map
        energyMapsCompleted += 1

        if replaceBlocks {
            let today = Calendar.current.startOfDay(for: Date())
            flowBlocks.removeAll { Calendar.current.isDate($0.scheduledDay, inSameDayAs: today) }
            flowBlocks.append(contentsOf: map.suggestedBlocks(for: today))
        }
        recordActivity()
        bumpHighestMomentum()
    }

    func setPrimaryOutcome(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let wasUnset = !(dayOutcome?.isSet ?? false)
        dayOutcome = DayOutcome(primaryOutcome: trimmed)
        if wasUnset {
            outcomesLocked += 1
        }
        recordActivity()
        bumpHighestMomentum()
    }

    func togglePrimaryOutcomeCompleted() {
        guard var outcome = dayOutcome, outcome.isSet else { return }
        outcome.isCompleted.toggle()
        dayOutcome = outcome
        recordActivity()
    }

    func canLink(taskEnergy: EnergyLevel, to block: FlowBlock) -> Bool {
        EnergyDayMap.allows(taskEnergy: taskEnergy, in: block.energyLevel)
    }

    func linkTask(_ taskId: UUID, toBlock blockId: UUID) -> Bool {
        guard let task = tasks.first(where: { $0.id == taskId }),
              let index = flowBlocks.firstIndex(where: { $0.id == blockId }) else { return false }
        guard canLink(taskEnergy: task.energyLevel, to: flowBlocks[index]) else { return false }
        flowBlocks[index].linkedTaskId = taskId
        flowBlocks[index].title = task.title
        return true
    }

    // MARK: - Flow Blocks

    var todaysFlowBlocks: [FlowBlock] {
        let today = Calendar.current.startOfDay(for: Date())
        return flowBlocks
            .filter { Calendar.current.isDate($0.scheduledDay, inSameDayAs: today) }
            .sorted { lhs, rhs in
                lhs.startHour == rhs.startHour
                    ? lhs.startMinute < rhs.startMinute
                    : lhs.startHour < rhs.startHour
            }
    }

    func addFlowBlock(_ block: FlowBlock) -> Bool {
        // Peak tasks / Peak blocks rule when linking later; block itself must match day map if set
        if let map = energyDayMap, map.isToday {
            if block.energyLevel == .peak && map.dayEnergy == .low {
                return false
            }
        }
        flowBlocks.append(block)
        recordActivity()
        return true
    }

    func applyGuidedRoutine(_ routine: GuidedRoutine, for day: Date = Date()) {
        var blocks = routine.makeFlowBlocks(for: day)
        if let map = energyDayMap, map.isToday {
            blocks = blocks.filter { EnergyDayMap.allows(taskEnergy: $0.energyLevel, in: map.dayEnergy) || $0.energyLevel != .peak || map.dayEnergy != .low }
            // On low days, convert peak steps to steady
            if map.dayEnergy == .low {
                blocks = blocks.map { block in
                    var b = block
                    if b.energyLevel == .peak { b.energyLevel = .steady }
                    return b
                }
            }
        }
        flowBlocks.append(contentsOf: blocks)
        recordActivity()
    }

    func toggleFlowBlockCompletion(id: UUID) {
        guard let index = flowBlocks.firstIndex(where: { $0.id == id }) else { return }
        let wasCompleted = flowBlocks[index].isCompleted
        flowBlocks[index].isCompleted.toggle()
        if flowBlocks[index].isCompleted && !wasCompleted {
            if flowBlocks[index].energyLevel == .peak {
                peakBlocksCompleted += 1
            }
            recordActivity()
            bumpHighestMomentum()
        }
    }

    func deleteFlowBlock(id: UUID) {
        flowBlocks.removeAll { $0.id == id }
    }

    var momentumBreakdown: MomentumBreakdown {
        MomentumCalculator.breakdown(for: self)
    }

    private func bumpHighestMomentum() {
        let score = momentumBreakdown.total
        if score > highestMomentum {
            highestMomentum = score
        }
        markCommitmentKeptIfNeeded()
    }

    var todaysFlowProgress: Double {
        let blocks = todaysFlowBlocks
        guard !blocks.isEmpty else { return 0 }
        let done = blocks.filter(\.isCompleted).count
        return Double(done) / Double(blocks.count)
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
        defaultCategory = "Outcomes"
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
        weeklyPlan = WeeklyPlan()
        flowBlocks = []
        energyDayMap = nil
        dayOutcome = nil
        energyMapsCompleted = 0
        outcomesLocked = 0
        peakBlocksCompleted = 0
        highestMomentum = 0
        commitmentsKept = 0
        defaults.set(false, forKey: Keys.templatesSeeded)
        defaults.set(false, forKey: Keys.nicheTemplatesSeeded)
        seedTemplatesIfNeeded()
        migrateNicheTemplatesIfNeeded()
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func saveOptional<T: Encodable>(_ value: T?, forKey key: String) {
        guard let value else {
            defaults.removeObject(forKey: key)
            return
        }
        save(value, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
