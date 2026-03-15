// Services/CircadianScoringService.swift
// Serviço de cálculo do Score de Alinhamento Circadiano

import Foundation
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "Scoring")

actor CircadianScoringService {

    // MARK: - Score Calculation

    func calculateScore(
        from entries: [SleepEntry],
        profile: CircadianProfile
    ) async throws -> CircadianScore {
        guard entries.count >= 3 else {
            throw AppError.insufficientData
        }

        let recentEntries = Array(entries.prefix(7))

        let sleepScore = calculateSleepAlignmentScore(entries: recentEntries, profile: profile)
        let consistencyScore = calculateConsistencyScore(entries: recentEntries)
        let qualityScore = calculateQualityScore(entries: recentEntries)
        let durationScore = calculateDurationScore(entries: recentEntries)

        let overall = (sleepScore * 0.35 + consistencyScore * 0.30 + qualityScore * 0.20 + durationScore * 0.15)
        let clamped = min(max(overall, 0), 100)

        logger.debug("Score calculado: overall=\(clamped), sleep=\(sleepScore), consistency=\(consistencyScore)")

        return CircadianScore(
            date: Date(),
            overallScore: clamped,
            sleepAlignmentScore: sleepScore,
            lightExposureScore: qualityScore,
            activityScore: durationScore,
            consistencyScore: consistencyScore,
            weeklyTrend: await calculateWeeklyTrend(entries: entries, profile: profile)
        )
    }

    // MARK: - Sub-Score Calculators

    private func calculateSleepAlignmentScore(
        entries: [SleepEntry],
        profile: CircadianProfile
    ) -> Double {
        let idealBedHour = profile.chronotype.idealBedtimeHour
        let idealWakeHour = profile.chronotype.idealWakeHour

        let scores = entries.map { entry -> Double in
            let calendar = Calendar.current
            let bedHour = calendar.component(.hour, from: entry.bedtime)
            let wakeHour = calendar.component(.hour, from: entry.wakeTime)

            let bedDiff = min(abs(bedHour - idealBedHour), 12)
            let wakeDiff = min(abs(wakeHour - idealWakeHour), 12)

            let bedScore = max(0, 100 - Double(bedDiff) * 12.5)
            let wakeScore = max(0, 100 - Double(wakeDiff) * 12.5)
            return (bedScore + wakeScore) / 2
        }

        return scores.reduce(0, +) / Double(scores.count)
    }

    private func calculateConsistencyScore(entries: [SleepEntry]) -> Double {
        guard entries.count >= 2 else { return 50 }

        let calendar = Calendar.current
        let bedtimes = entries.map { Double(calendar.component(.hour, from: $0.bedtime)) * 60
            + Double(calendar.component(.minute, from: $0.bedtime)) }

        let mean = bedtimes.reduce(0, +) / Double(bedtimes.count)
        let variance = bedtimes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(bedtimes.count)
        let stdDev = sqrt(variance)

        // stdDev <= 15 min → 100pts; stdDev >= 90 min → 0pts
        let score = max(0, 100 - (stdDev / 90) * 100)
        return min(score, 100)
    }

    private func calculateQualityScore(entries: [SleepEntry]) -> Double {
        let avgQuality = entries.map { Double($0.sleepQualityScore) }.reduce(0, +) / Double(entries.count)
        return (avgQuality / 10) * 100
    }

    private func calculateDurationScore(entries: [SleepEntry]) -> Double {
        let idealHours = 7.5
        let scores = entries.map { entry -> Double in
            let hours = entry.totalSleepHours
            let diff = abs(hours - idealHours)
            return max(0, 100 - diff * 20)
        }
        return scores.reduce(0, +) / Double(scores.count)
    }

    private func calculateWeeklyTrend(
        entries: [SleepEntry],
        profile: CircadianProfile
    ) async -> Double {
        guard entries.count >= 7 else { return 0 }

        let recentWeek = Array(entries.prefix(7))
        let previousWeek = Array(entries.dropFirst(7).prefix(7))

        guard !previousWeek.isEmpty else { return 0 }

        let recentAvg = recentWeek.map { Double($0.sleepQualityScore) }.reduce(0, +) / Double(recentWeek.count)
        let previousAvg = previousWeek.map { Double($0.sleepQualityScore) }.reduce(0, +) / Double(previousWeek.count)

        guard previousAvg > 0 else { return 0 }
        return ((recentAvg - previousAvg) / previousAvg) * 100
    }

    // MARK: - Peak Performance Windows

    func calculatePeakCognitiveWindows(for profile: CircadianProfile) -> [TimeWindow] {
        let wakeHour = profile.chronotype.idealWakeHour
        var windows: [TimeWindow] = []

        // Janela 1: 2-4h após acordar (pico primário)
        let peak1Start = wakeHour + 2
        let peak1End = wakeHour + 4
        windows.append(TimeWindow(
            startHour: peak1Start % 24,
            endHour: peak1End % 24,
            label: "Pico Primário",
            intensity: .high,
            description: "Melhor janela para tarefas complexas e criativas"
        ))

        // Janela 2: 6-8h após acordar (pico secundário)
        let peak2Start = wakeHour + 6
        let peak2End = wakeHour + 8
        windows.append(TimeWindow(
            startHour: peak2Start % 24,
            endHour: peak2End % 24,
            label: "Pico Secundário",
            intensity: .medium,
            description: "Bom para reuniões e trabalho colaborativo"
        ))

        return windows
    }
}

// MARK: - Supporting Types

struct TimeWindow {
    enum Intensity { case high, medium, low }
    let startHour: Int
    let endHour: Int
    let label: String
    let intensity: Intensity
    let description: String

    var formattedRange: String {
        let start = String(format: "%02d:00", startHour)
        let end = String(format: "%02d:00", endHour)
        return "\(start) – \(end)"
    }
}
