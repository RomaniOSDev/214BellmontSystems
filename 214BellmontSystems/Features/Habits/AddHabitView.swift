import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss

    let existingHabit: Habit?
    let onSave: (String) -> Void

    @State private var name = ""
    @State private var errorMessage = ""
    @State private var shakeTrigger = 0

    init(existingHabit: Habit? = nil, onSave: @escaping (String) -> Void) {
        self.existingHabit = existingHabit
        self.onSave = onSave
        _name = State(initialValue: existingHabit?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                Form {
                    Section {
                        TextField("Habit name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingHabit == nil ? "Add Anchor" : "Edit Anchor")
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
                        saveHabit()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func saveHabit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a habit name"
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        FeedbackService.mediumAction()
        onSave(trimmed)
        dismiss()
    }
}
