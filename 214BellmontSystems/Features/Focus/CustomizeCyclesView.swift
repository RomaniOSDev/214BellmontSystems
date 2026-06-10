import SwiftUI

struct CustomizeCyclesView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var focusMinutes: Double
    @State private var breakMinutes: Double

    init() {
        _focusMinutes = State(initialValue: 25)
        _breakMinutes = State(initialValue: 5)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                Form {
                    Section("Focus Duration") {
                        Stepper(
                            "\(Int(focusMinutes)) minutes",
                            value: $focusMinutes,
                            in: 5...60,
                            step: 5
                        )
                        .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section("Break Duration") {
                        Stepper(
                            "\(Int(breakMinutes)) minutes",
                            value: $breakMinutes,
                            in: 1...30,
                            step: 1
                        )
                        .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Customize Cycles")
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
                        store.focusDurationMin = Int(focusMinutes)
                        store.breakDurationMin = Int(breakMinutes)
                        FeedbackService.success()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                focusMinutes = Double(store.focusDurationMin)
                breakMinutes = Double(store.breakDurationMin)
            }
        }
    }
}
