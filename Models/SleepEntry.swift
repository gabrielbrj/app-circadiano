// Models/SleepEntry.swift
// Modelo SwiftData para registros de sono do usuário

import SwiftData
import Foundation

@Model
final class SleepEntry {

    var id: UUID
    var bedtime: Date
    var wakeTime: Date
    var sleepQualityScore: Int      // 1-10
    var deepSleepMinutes: Int
    var remSleepMinutes: Int
    var lightSleepMinutes: Int
    var awakeMinutes: Int
    var heartRateAvg: Double
    var heartRateMin: Double
    var notes: String
    var createdAt: Date

    // Relação com score circadiano calculado
    @Relationship(deleteRule: .cascade)
    var circadianScore: CircadianScore?

    init(
        id: UUID = UUID(),
        bedtime: Date,
        wakeTime: Date,
        sleepQualityScore: Int = 5,
        deepSleepMinutes: Int = 0,
        remSleepMinutes: Int = 0,
        lightSleepMinutes: Int = 0,
        awakeMinutes: Int = 0,
        heartRateAvg: Double = 0,
        heartRateMin: Double = 0,
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.sleepQualityScore = sleepQualityScore
        self.deepSleepMinutes = deepSleepMinutes
        self.remSleepMinutes = remSleepMinutes
        self.lightSleepMinutes = lightSleepMinutes
        self.awakeMinutes = awakeMinutes
        self.heartRateAvg = heartRateAvg
        self.heartRateMin = heartRateMin
        self.notes = notes
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    var totalSleepMinutes: Int {
        deepSleepMinutes + remSleepMinutes + lightSleepMinutes
    }

    var totalSleepHours: Double {
        Double(totalSleepMinutes) / 60.0
    }

    var sleepDuration: TimeInterval {
        wakeTime.timeIntervalSince(bedtime)
    }

    var sleepEfficiency: Double {
        guard sleepDuration > 0 else { return 0 }
        let totalInBed = sleepDuration / 60
        return min(Double(totalSleepMinutes) / totalInBed * 100, 100)
    }

    var qualityLabel: String {
        switch sleepQualityScore {
        case 8...10: return "Excelente"
        case 6...7:  return "Bom"
        case 4...5:  return "Regular"
        default:     return "Ruim"
        }
    }

    // MARK: - Sample Data

    static var sampleEntries: [SleepEntry] {
        let calendar = Calendar.current
        return (0..<7).map { dayOffset in
            let bedtime = calendar.date(
                byAdding: .day, value: -dayOffset,
                to: calendar.date(from: DateComponents(hour: 23, minute: 30))!
            )!
            let wakeTime = calendar.date(byAdding: .hour, value: 7, to: bedtime)!
            return SleepEntry(
                bedtime: bedtime,
                wakeTime: wakeTime,
                sleepQualityScore: Int.random(in: 5...9),
                deepSleepMinutes: Int.random(in: 60...100),
                remSleepMinutes: Int.random(in: 80...120),
                lightSleepMinutes: Int.random(in: 120...180),
                awakeMinutes: Int.random(in: 5...20),
                heartRateAvg: Double.random(in: 58...68),
                heartRateMin: Double.random(in: 48...55)
            )
        }
    }
}
