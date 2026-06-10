import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        settingsCard
                        versionFooter
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarStyle()
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackService.lightTap() }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    NotificationCenter.default.post(name: .dataReset, object: nil)
                    FeedbackService.warning()
                }
            } message: {
                Text("This will permanently delete all tasks, habits, focus history, and achievements. This action cannot be undone.")
            }
        }
    }

    private var statsCard: some View {
        AppCard {
            VStack(spacing: 16) {
                HStack {
                    AppSectionHeader(title: "Statistics", subtitle: "Your activity overview")
                    Spacer()
                    AppIconCircle(icon: "chart.pie.fill", size: 40, iconColor: Color("AppAccent"))
                }

                HStack(spacing: 0) {
                    AppMetricTile(
                        value: "\(store.tasks.count + store.habits.count)",
                        label: "Entries",
                        icon: "tray.full.fill"
                    )
                    AppMetricTile(
                        value: "\(store.totalMinutesUsed)",
                        label: "Minutes",
                        icon: "clock.fill"
                    )
                    AppMetricTile(
                        value: "\(store.streakDays)",
                        label: "Streak",
                        icon: "flame.fill"
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var settingsCard: some View {
        AppCard(padding: 8) {
            VStack(spacing: 0) {
                SettingsRowCell(title: "Rate Us", icon: "star.fill") {
                    rateApp()
                }
                divider
                SettingsRowCell(title: "Privacy", icon: "hand.raised.fill") {
                    openLink(.privacyPolicy)
                }
                divider
                SettingsRowCell(title: "Terms", icon: "doc.text.fill") {
                    openLink(.termsOfService)
                }
                divider
                SettingsRowCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true) {
                    showResetAlert = true
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppTextPrimary").opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 60)
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
    }

    private func openLink(_ link: AppLink) {
        FeedbackService.lightTap()
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        FeedbackService.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
