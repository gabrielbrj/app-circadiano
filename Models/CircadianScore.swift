// Models/CircadianScore.swift
// Score de alinhamento circadiano calculado diariamente

import SwiftData
import Foundation

@Model
final class CircadianScore {

    var id: UUID
    var date: Date
    var overallScore: Double       // 0-100
    var sleepAlignmentScore: Double
    var lightExposureScore: Double
    var activityScore: Double
    var consistencyScore: Double
    var weeklyTrend: Double        // delta percentual vs semana anterior
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        overallScore: Double = 0,
        sleepAlignmentScore: Double = 0,
        lightExposureScore: Double = 0,
        activityScore: Double = 0,
        consistencyScore: Double = 0,
        weeklyTrend: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.overallScore = overallScore
        self.sleepAlignmentScore = sleepAlignmentScore
        self.lightExposureScore = lightExposureScore
        self.activityScore = activityScore
        self.consistencyScore = consistencyScore
        self.weeklyTrend = weeklyTrend
        self.createdAt = createdAt
    }

    var scoreLabel: String {
        switch overallScore {
        case 85...100: return "Excelente"
        case 70..<85:  return "Bom"
        case 50..<70:  return "Regular"
        case 30..<50:  return "Atenção"
        default:       return "Crítico"
        }
    }

    var scoreEmoji: String {
        switch overallScore {
        case 85...100: return "🌟"
        case 70..<85:  return "✅"
        case 50..<70:  return "⚠️"
        default:       return "🔴"
        }
    }

    var trendLabel: String {
        if weeklyTrend > 5 { return "↑ Melhorando" }
        if weeklyTrend < -5 { return "↓ Piorando" }
        return "→ Estável"
    }

    var trendIsPositive: Bool {
        weeklyTrend >= 0
    }

    // MARK: - Sample Data

    static var sampleScores: [CircadianScore] {
        let calendar = Calendar.current
        let baseScores: [Double] = [72, 68, 75, 81, 78, 85, 82]
        return baseScores.enumerated().map { index, score in
            let date = calendar.date(byAdding: .day, value: -(6 - index), to: Date())!
            return CircadianScore(
                date: date,
                overallScore: score,
                sleepAlignmentScore: score + Double.random(in: -8...8),
                lightExposureScore: score + Double.random(in: -10...10),
                activityScore: score + Double.random(in: -12...12),
                consistencyScore: score + Double.random(in: -5...5),
                weeklyTrend: Double.random(in: -10...15)
            )
        }
    }

    static var todaySample: CircadianScore {
        CircadianScore(
            date: Date(),
            overallScore: 78,
            sleepAlignmentScore: 82,
            lightExposureScore: 74,
            activityScore: 71,
            consistencyScore: 85,
            weeklyTrend: 6.5
        )
    }
}
