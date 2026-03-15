// Models/CircadianProfile.swift
// Perfil circadiano do usuário com cronotipo e preferências

import SwiftData
import Foundation

@Model
final class CircadianProfile {

    var id: UUID
    var name: String
    var birthDate: Date
    var chronotype: Chronotype
    var wakeTargetTime: Date
    var sleepTargetTime: Date
    var caffeineCutoffHour: Int     // hora do dia para parar cafeína
    var exercisePreferenceHour: Int // hora preferida para exercício
    var lightExposureReminder: Bool
    var smartAlarmEnabled: Bool
    var smartAlarmWindowMinutes: Int // janela antes do horário ideal
    var subscriptionTier: SubscriptionTier
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        birthDate: Date = Date(),
        chronotype: Chronotype = .intermediate,
        wakeTargetTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
        sleepTargetTime: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date(),
        caffeineCutoffHour: Int = 14,
        exercisePreferenceHour: Int = 7,
        lightExposureReminder: Bool = true,
        smartAlarmEnabled: Bool = true,
        smartAlarmWindowMinutes: Int = 30,
        subscriptionTier: SubscriptionTier = .free,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.chronotype = chronotype
        self.wakeTargetTime = wakeTargetTime
        self.sleepTargetTime = sleepTargetTime
        self.caffeineCutoffHour = caffeineCutoffHour
        self.exercisePreferenceHour = exercisePreferenceHour
        self.lightExposureReminder = lightExposureReminder
        self.smartAlarmEnabled = smartAlarmEnabled
        self.smartAlarmWindowMinutes = smartAlarmWindowMinutes
        self.subscriptionTier = subscriptionTier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static var sample: CircadianProfile {
        CircadianProfile(
            name: "Ana Carolina",
            birthDate: Calendar.current.date(from: DateComponents(year: 1985, month: 6, day: 15))!,
            chronotype: .intermediate,
            subscriptionTier: .premium
        )
    }
}

// MARK: - Enums

enum Chronotype: String, Codable, CaseIterable {
    case strongMorning = "strong_morning"
    case moderateMorning = "moderate_morning"
    case intermediate = "intermediate"
    case moderateEvening = "moderate_evening"
    case strongEvening = "strong_evening"

    var label: String {
        switch self {
        case .strongMorning:    return "Vespertino Forte"
        case .moderateMorning:  return "Matutino Moderado"
        case .intermediate:     return "Intermediário"
        case .moderateEvening:  return "Vespertino Moderado"
        case .strongEvening:    return "Vespertino Forte"
        }
    }

    var description: String {
        switch self {
        case .strongMorning:
            return "Acorda naturalmente muito cedo, pico de energia pela manhã"
        case .moderateMorning:
            return "Prefere acordar cedo, produtivo principalmente de manhã"
        case .intermediate:
            return "Sem preferência forte, se adapta a diferentes horários"
        case .moderateEvening:
            return "Prefere acordar mais tarde, mais energético à tarde/noite"
        case .strongEvening:
            return "Dificuldade em dormir cedo, pico de energia noturno"
        }
    }

    var emoji: String {
        switch self {
        case .strongMorning, .moderateMorning: return "🌅"
        case .intermediate:                    return "⚖️"
        case .moderateEvening, .strongEvening: return "🌙"
        }
    }

    var idealBedtimeHour: Int {
        switch self {
        case .strongMorning:    return 21
        case .moderateMorning:  return 22
        case .intermediate:     return 23
        case .moderateEvening:  return 0
        case .strongEvening:    return 1
        }
    }

    var idealWakeHour: Int {
        switch self {
        case .strongMorning:    return 5
        case .moderateMorning:  return 6
        case .intermediate:     return 7
        case .moderateEvening:  return 8
        case .strongEvening:    return 9
        }
    }
}

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case premium = "premium"

    var label: String {
        switch self {
        case .free:    return "Gratuito"
        case .premium: return "Premium"
        }
    }
}
