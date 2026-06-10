import Foundation

struct WeeklyReviewData {
    let tasksCompleted: Int
    let focusMinutes: Int
    let focusSessions: Int
    let habitCheckIns: Int
    let dailyFocusMinutes: [(date: Date, minutes: Int)]
}
