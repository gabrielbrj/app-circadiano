// ViewModels/SleepViewModel.swift
// ViewModel de registro e análise de sono

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "SleepVM")

@Observable
final class SleepViewModel {

    // Form state
    var bedtime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
    var wakeTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    var sleepQuality: Int = 6
    var deepSleepMinutes: Int = 0
    var remSleepMinutes: Int = 0
    var lightSleepMinutes: Int = 0
    var awakeMinutes: Int = 0
    var notes: String = ""

    // UI state
    var isLoading = false
    var isSaving = false
    var error: AppError?
    var showingForm = false
    var selectedEntry: SleepEntry?
    var healthKitImportAvailable = false

    private let healthKitService: HealthKitService
    private let notificationService: NotificationService

    init(
        healthKitService: HealthKitService = HealthKitService(),
        notificationService: NotificationService = NotificationService()
    ) {
        self.healthKitService = healthKitService
        self.notificationService = notificationService
    }

    // MARK: - Actions

    func importFromHealthKit() async -> SleepEntry? {
        isLoading = true
        defer { isLoading = false }

        do {
            try await healthKitService.requestAuthorization()
            let sleepData = try await healthKitService.fetchSleepData(for: Date())
            let hrStats = try await healthKitService.fetchHeartRateStats(for: Date())

            let entry = SleepEntry(
                bedtime: sleepData.bedtime ?? bedtime,
                wakeTime: sleepData.wakeTime ?? wakeTime,
                deepSleepMinutes: sleepData.deepSleepMinutes,
                remSleepMinutes: sleepData.remSleepMinutes,
                lightSleepMinutes: sleepData.lightSleepMinutes,
                awakeMinutes: sleepData.awakeMinutes,
                heartRateAvg: hrStats.average,
                heartRateMin: hrStats.minimum
            )

            populateForm(from: entry)
            logger.info("Dados importados do HealthKit com sucesso")
            return entry
        } catch let appError as AppError {
            error = appError
            logger.error("Erro ao importar HealthKit: \(appError.localizedDescription ?? "")")
            return nil
        } catch {
            self.error = .unknown
            return nil
        }
    }

    func buildEntry() -> SleepEntry {
        SleepEntry(
            bedtime: bedtime,
            wakeTime: wakeTime,
            sleepQualityScore: sleepQuality,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes,
            lightSleepMinutes: lightSleepMinutes,
            awakeMinutes: awakeMinutes,
            notes: notes
        )
    }

    func resetForm() {
        bedtime = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
        wakeTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
        sleepQuality = 6
        deepSleepMinutes = 0
        remSleepMinutes = 0
        lightSleepMinutes = 0
        awakeMinutes = 0
        notes = ""
    }

    private func populateForm(from entry: SleepEntry) {
        bedtime = entry.bedtime
        wakeTime = entry.wakeTime
        sleepQuality = entry.sleepQualityScore
        deepSleepMinutes = entry.deepSleepMinutes
        remSleepMinutes = entry.remSleepMinutes
        lightSleepMinutes = entry.lightSleepMinutes
        awakeMinutes = entry.awakeMinutes
    }

    // MARK: - Computed

    var formattedDuration: String {
        let minutes = Int(wakeTime.timeIntervalSince(bedtime) / 60)
        guard minutes > 0 else { return "--" }
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }

    var qualityLabel: String {
        switch sleepQuality {
        case 9...10: return "Excelente 🌟"
        case 7...8:  return "Bom ✅"
        case 5...6:  return "Regular 🟡"
        case 3...4:  return "Ruim ⚠️"
        default:     return "Muito Ruim 🔴"
        }
    }

    var qualityColor: Color {
        switch sleepQuality {
        case 7...10: return .appSuccess
        case 5...6:  return .appWarning
        default:     return .appError
        }
    }

    var isFormValid: Bool {
        wakeTime > bedtime
    }
}
