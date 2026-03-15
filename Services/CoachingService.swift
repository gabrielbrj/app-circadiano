// Services/CoachingService.swift
// Serviço de geração de recomendações circadianas personalizadas

import Foundation
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "Coaching")

actor CoachingService {

    // MARK: - Recommendation Generation

    func generateDailyRecommendations(
        profile: CircadianProfile,
        recentEntries: [SleepEntry],
        currentScore: CircadianScore?
    ) async -> [CoachingRecommendation] {
        var recommendations: [CoachingRecommendation] = []
        let calendar = Calendar.current
        let now = Date()

        // Recomendação de luz matinal
        let wakeHour = profile.chronotype.idealWakeHour
        if let lightTime = calendar.date(from: DateComponents(hour: wakeHour, minute: 30)) {
            recommendations.append(CoachingRecommendation(
                category: .light,
                title: "Exposição à Luz Solar",
                body: buildLightRecommendation(profile: profile),
                scheduledTime: lightTime,
                priority: .high
            ))
        }

        // Recomendação de cafeína
        if let caffeineTime = calendar.date(from: DateComponents(hour: profile.caffeineCutoffHour)) {
            recommendations.append(CoachingRecommendation(
                category: .caffeine,
                title: "Limite de Cafeína",
                body: buildCaffeineRecommendation(cutoffHour: profile.caffeineCutoffHour),
                scheduledTime: caffeineTime,
                priority: .medium
            ))
        }

        // Recomendação de exercício
        if let exerciseTime = calendar.date(from: DateComponents(hour: profile.exercisePreferenceHour)) {
            recommendations.append(CoachingRecommendation(
                category: .exercise,
                title: "Janela Ideal para Exercício",
                body: buildExerciseRecommendation(profile: profile),
                scheduledTime: exerciseTime,
                priority: .medium
            ))
        }

        // Recomendação de sono
        let bedHour = profile.chronotype.idealBedtimeHour
        let windDownHour = bedHour >= 2 ? bedHour - 2 : 22
        if let sleepTime = calendar.date(from: DateComponents(hour: windDownHour)) {
            recommendations.append(CoachingRecommendation(
                category: .sleep,
                title: "Ritual de Sono",
                body: buildSleepRecommendation(profile: profile, entries: recentEntries),
                scheduledTime: sleepTime,
                priority: .high
            ))
        }

        // Pico cognitivo
        let peakHour = wakeHour + 2
        if let cognitiveTime = calendar.date(from: DateComponents(hour: peakHour % 24)) {
            recommendations.append(CoachingRecommendation(
                category: .cognitive,
                title: "Pico de Desempenho Mental",
                body: buildCognitiveRecommendation(profile: profile),
                scheduledTime: cognitiveTime,
                priority: .high
            ))
        }

        logger.debug("Geradas \(recommendations.count) recomendações para \(profile.name)")
        return recommendations.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }

    // MARK: - Message Builders

    private func buildLightRecommendation(profile: CircadianProfile) -> String {
        "Como \(profile.chronotype.label.lowercased()), exposição à luz solar logo após acordar é especialmente importante. 10-15 minutos de luz natural suprime melatonina e sincroniza seu relógio biológico interno (SCN)."
    }

    private func buildCaffeineRecommendation(cutoffHour: Int) -> String {
        "A cafeína tem meia-vida de 5-6 horas. Após as \(cutoffHour)h, o consumo pode aumentar o tempo para adormecer e reduzir o sono profundo em até 20%, mesmo que você não sinta os efeitos."
    }

    private func buildExerciseRecommendation(profile: CircadianProfile) -> String {
        "Exercícios no período vespertino coincidem com o pico de temperatura corporal, maximizando força e desempenho. Para seu cronotipo, este horário não interfere na produção de melatonina noturna."
    }

    private func buildSleepRecommendation(profile: CircadianProfile, entries: [SleepEntry]) -> String {
        let avgQuality = entries.isEmpty ? 5 :
            entries.prefix(3).map { $0.sleepQualityScore }.reduce(0, +) / 3

        if avgQuality < 6 {
            return "Suas últimas noites mostraram qualidade abaixo do ideal. Reduza luzes azuis 2h antes de dormir, mantenha o quarto a 18-20°C e evite refeições pesadas após as \(profile.chronotype.idealBedtimeHour - 2)h."
        }
        return "Mantenha sua rotina atual. Dim as luzes e inicie atividades relaxantes para facilitar a transição ao sono no horário ideal para seu cronotipo."
    }

    private func buildCognitiveRecommendation(profile: CircadianProfile) -> String {
        let peakHour = profile.chronotype.idealWakeHour + 2
        return "Das \(peakHour % 24)h às \(peakHour + 2 % 24)h você está no pico de alerta cortical. Ideal para tomada de decisão, aprendizado e tarefas que exigem alta concentração ou criatividade."
    }
}
