// ViewModels/ProfileViewModel.swift
// ViewModel para perfil do usuário e configurações

import Foundation
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "ProfileVM")

@Observable
final class ProfileViewModel {

    // Form fields
    var name: String = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    var selectedChronotype: Chronotype = .intermediate
    var caffeineCutoffHour: Int = 14
    var exercisePreferenceHour: Int = 7
    var lightExposureReminder: Bool = true
    var smartAlarmEnabled: Bool = true
    var smartAlarmWindowMinutes: Int = 30

    // UI state
    var isSaving = false
    var isLoading = false
    var error: AppError?
    var showingChronotypeQuiz = false
    var showingSubscription = false

    private let notificationService: NotificationService

    init(notificationService: NotificationService = NotificationService()) {
        self.notificationService = notificationService
    }

    // MARK: - Load from Profile

    func load(from profile: CircadianProfile?) {
        guard let profile else { return }
        name = profile.name
        birthDate = profile.birthDate
        selectedChronotype = profile.chronotype
        caffeineCutoffHour = profile.caffeineCutoffHour
        exercisePreferenceHour = profile.exercisePreferenceHour
        lightExposureReminder = profile.lightExposureReminder
        smartAlarmEnabled = profile.smartAlarmEnabled
        smartAlarmWindowMinutes = profile.smartAlarmWindowMinutes
    }

    // MARK: - Save

    func save(to profile: CircadianProfile) async {
        isSaving = true
        defer { isSaving = false }

        profile.name = name
        profile.birthDate = birthDate
        profile.chronotype = selectedChronotype
        profile.caffeineCutoffHour = caffeineCutoffHour
        profile.exercisePreferenceHour = exercisePreferenceHour
        profile.lightExposureReminder = lightExposureReminder
        profile.smartAlarmEnabled = smartAlarmEnabled
        profile.smartAlarmWindowMinutes = smartAlarmWindowMinutes
        profile.updatedAt = Date()

        if lightExposureReminder {
            do {
                try await notificationService.scheduleCoachingNotifications(for: profile)
            } catch let appError as AppError {
                error = appError
                logger.error("Falha ao agendar notificações: \(appError.localizedDescription ?? "")")
            } catch {
                self.error = .unknown
            }
        }

        logger.info("Perfil salvo para \(profile.name)")
    }

    func createNewProfile() -> CircadianProfile {
        CircadianProfile(
            name: name,
            birthDate: birthDate,
            chronotype: selectedChronotype,
            caffeineCutoffHour: caffeineCutoffHour,
            exercisePreferenceHour: exercisePreferenceHour,
            lightExposureReminder: lightExposureReminder,
            smartAlarmEnabled: smartAlarmEnabled,
            smartAlarmWindowMinutes: smartAlarmWindowMinutes
        )
    }

    // MARK: - Computed

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var caffeineCutoffLabel: String {
        String(format: "%02d:00", caffeineCutoffHour)
    }

    var exerciseTimeLabel: String {
        String(format: "%02d:00", exercisePreferenceHour)
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && age >= 13
    }
}
