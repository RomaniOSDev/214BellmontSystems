import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    if markdownContent.isEmpty {
                        ProgressView()
                            .tint(Color("AppPrimary"))
                            .padding(.top, 40)
                    } else {
                        Group {
                            if let attributed = try? AttributedString(markdown: markdownContent) {
                                Text(attributed)
                            } else {
                                Text(markdownContent)
                            }
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(Color("AppPrimary"))
            .onAppear {
                loadPolicy()
            }
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            markdownContent = "Privacy policy unavailable."
            return
        }
        markdownContent = content
    }
}
