// CircadiaCareApp.swift
// Entry point principal do aplicativo CircadiaCare
// Plataforma de regulação circadiana com base em dados fisiológicos

import SwiftUI
import SwiftData
import UserNotifications
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "App")

@main
struct CircadiaCareApp: App {

    @State private var notificationDelegate = NotificationDelegate()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SleepEntry.self,
            CircadianProfile.self,
            CoachingRecommendation.self,
            CircadianScore.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            logger.fault("Falha ao criar ModelContainer: \(error.localizedDescription)")
            fatalError("Não foi possível criar o ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestNotificationPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func requestNotificationPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                logger.info("Permissão de notificação: \(granted)")
            } catch {
                logger.error("Erro ao solicitar permissão de notificação: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Notification Delegate

@Observable
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
}
