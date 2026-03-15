// Services/NotificationService.swift
// Serviço de agendamento de notificações circadianas

import UserNotifications
import Foundation
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "Notifications")

actor NotificationService {

    private let center = UNUserNotificationCenter.current()

    // MARK: - Smart Alarm

    func scheduleSmartAlarm(
        targetWakeTime: Date,
        windowMinutes: Int
    ) async throws {
        let earliestWake = targetWakeTime.addingTimeInterval(-Double(windowMinutes) * 60)

        let content = UNMutableNotificationContent()
        content.title = "Despertador Inteligente 🌅"
        content.body = "Você está em fase de sono leve. Hora de acordar com energia!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "SMART_ALARM"

        let components = Calendar.current.dateComponents([.hour, .minute], from: earliestWake)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "smartAlarm",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Despertador inteligente agendado para \(earliestWake)")
        } catch {
            logger.error("Falha ao agendar despertador: \(error.localizedDescription)")
            throw AppError.notificationScheduleFailed(error.localizedDescription)
        }
    }

    // MARK: - Coaching Notifications

    func scheduleCoachingNotifications(for profile: CircadianProfile) async throws {
        await cancelAllCoachingNotifications()

        try await scheduleLightExposureReminder(wakeHour: profile.chronotype.idealWakeHour)
        try await scheduleCaffeineReminder(cutoffHour: profile.caffeineCutoffHour)
        try await scheduleSleepWindDownReminder(bedHour: profile.chronotype.idealBedtimeHour)

        logger.info("Notificações de coaching agendadas para cronotipo \(profile.chronotype.rawValue)")
    }

    private func scheduleLightExposureReminder(wakeHour: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "☀️ Exposição à Luz Solar"
        content.body = "10-15 minutos de luz natural agora ancora seu relógio biológico"
        content.sound = .default
        content.categoryIdentifier = "COACHING"

        var components = DateComponents()
        components.hour = wakeHour
        components.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "lightExposure", content: content, trigger: trigger)

        try await center.add(request)
    }

    private func scheduleCaffeineReminder(cutoffHour: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "☕ Última Dose de Cafeína"
        content.body = "Evite cafeína após este horário para proteger seu sono"
        content.sound = .default
        content.categoryIdentifier = "COACHING"

        var components = DateComponents()
        components.hour = cutoffHour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "caffeineReminder", content: content, trigger: trigger)

        try await center.add(request)
    }

    private func scheduleSleepWindDownReminder(bedHour: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "🌙 Hora de Relaxar"
        content.body = "Dim as luzes e reduza telas. Prepare-se para dormir no horário ideal."
        content.sound = .default
        content.categoryIdentifier = "COACHING"

        let windDownHour = max(bedHour - 2, 0)
        var components = DateComponents()
        components.hour = windDownHour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "windDown", content: content, trigger: trigger)

        try await center.add(request)
    }

    // MARK: - Cancellation

    func cancelAllCoachingNotifications() async {
        center.removePendingNotificationRequests(withIdentifiers: [
            "lightExposure", "caffeineReminder", "windDown"
        ])
    }

    func cancelSmartAlarm() async {
        center.removePendingNotificationRequests(withIdentifiers: ["smartAlarm"])
    }
}
