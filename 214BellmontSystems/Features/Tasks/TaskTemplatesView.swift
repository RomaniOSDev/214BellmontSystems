import SwiftUI

struct TaskTemplatesView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showAddTemplate = false
    @State private var newTitle = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                if store.taskTemplates.isEmpty {
                    AppEmptyState(
                        icon: "doc.on.doc",
                        title: "No templates",
                        message: "Create templates for tasks you add frequently."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.taskTemplates) { template in
                                TemplateCell(template: template) {
                                    store.addTaskFromTemplate(template)
                                    FeedbackService.success()
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteTemplate(id: template.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Flow Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddTemplate = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .appToolbarStyle()
            .alert("New Template", isPresented: $showAddTemplate) {
                TextField("Title", text: $newTitle)
                Button("Cancel", role: .cancel) { newTitle = "" }
                Button("Add") {
                    let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    store.addTemplate(TaskTemplate(title: trimmed))
                    newTitle = ""
                    FeedbackService.success()
                }
            } message: {
                Text("Enter a template name for quick task creation.")
            }
        }
    }
}
