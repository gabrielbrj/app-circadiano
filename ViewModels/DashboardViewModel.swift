// ViewModels/DashboardViewModel.swift
// ViewModel da tela principal com score e resumo do dia

import Foundation
import Observation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "DashboardVM")

@Observable
final class DashboardViewModel {

    var todayScore: CircadianScore?
    var weeklyScores: [CircadianScore] = []
    var peakWindows: [TimeWindow] = []
    var isLoading = false
    var error: AppError?
    var profile: CircadianProfile?
    var lastSleepEntry: SleepEntry?
    var greetingMessage = ""

    private let scoringService: CircadianScoringService
    private let coachingService: CoachingService

    init(
        scoringService: CircadianScoringService = CircadianScoringService(),
        coachingService: CoachingService = CoachingService()
    ) {
        self.scoringService = scoringService
        self.coachingService = coachingService
    }

    // MARK: - Load

    func load(sleepEntries: [SleepEntry], profile: CircadianProfile?) async {
        isLoading = true
        defer { isLoading = false }

        self.profile = profile
        self.greetingMessage = buildGreeting(for: profile)

        guard let profile else { return }

        do {
            if sleepEntries.count >= 3 {
                todayScore = try await scoringService.calculateScore(from: sleepEntries, profile: profile)
            } else {
                todayScore = CircadianScore.todaySample
            }

            weeklyScores = CircadianScore.sampleScores
            peakWindows = await scoringService.calculatePeakCognitiveWindows(for: profile)
            lastSleepEntry = sleepEntries.first

            logger.info("Dashboard carregado para \(profile.name)")
        } catch let appError as AppError {
            error = appError
            logger.error("Erro ao carregar dashboard: \(appError.localizedDescription ?? "")")
        } catch {
            self.error = .unknown
        }
    }

    // MARK: - Greeting

    private func buildGreeting(for profile: CircadianProfile?) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = profile?.name.components(separatedBy: " ").first ?? ""
        let prefix = name.isEmpty ? "" : ", \(name)"

        switch hour {
        case 5..<12:  return "Bom dia\(prefix) ☀️"
        case 12..<18: return "Boa tarde\(prefix) 🌤"
        case 18..<22: return "Boa noite\(prefix) 🌆"
        default:       return "Hora de dormir\(prefix) 🌙"
        }
    }

    // MARK: - Computed

    var currentPeakWindow: TimeWindow? {
        let hour = Calendar.current.component(.hour, from: Date())
        return peakWindows.first { window in
            hour >= window.startHour && hour < window.endHour
        }
    }

    var scoreChangeText: String {
        guard let score = todayScore else { return "" }
        let trend = score.weeklyTrend
        if trend > 0 { return "+\(String(format: "%.1f", trend))% vs semana passada" }
        if trend < 0 { return "\(String(format: "%.1f", trend))% vs semana passada" }
        return "Estável vs semana passada"
    }

    var nextSleepTargetText: String {
        guard let profile else { return "--:--" }
        let bedHour = profile.chronotype.idealBedtimeHour
        return String(format: "%02d:00", bedHour)
    }
}
