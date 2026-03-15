// Models/CoachingRecommendation.swift
// Modelo para recomendações de coaching circadiano

import SwiftData
import Foundation

@Model
final class CoachingRecommendation {

    var id: UUID
    var category: RecommendationCategory
    var title: String
    var body: String
    var scheduledTime: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var priority: RecommendationPriority
    var generatedAt: Date
    var expiresAt: Date

    init(
        id: UUID = UUID(),
        category: RecommendationCategory,
        title: String,
        body: String,
        scheduledTime: Date? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        priority: RecommendationPriority = .medium,
        generatedAt: Date = Date(),
        expiresAt: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.body = body
        self.scheduledTime = scheduledTime
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.priority = priority
        self.generatedAt = generatedAt
        self.expiresAt = expiresAt
    }

    var isExpired: Bool {
        Date() > expiresAt
    }

    // MARK: - Sample Data

    static var sampleRecommendations: [CoachingRecommendation] {
        [
            CoachingRecommendation(
                category: .light,
                title: "Exposição à luz solar",
                body: "Exponha-se à luz solar natural por 10-15 minutos agora. Isso ancora seu relógio biológico e melhora o estado de alerta.",
                scheduledTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 30)),
                priority: .high
            ),
            CoachingRecommendation(
                category: .caffeine,
                title: "Última dose de cafeína",
                body: "Este é o horário ideal para sua última xícara de café. Consumir após as 14h pode prejudicar a qualidade do sono.",
                scheduledTime: Calendar.current.date(from: DateComponents(hour: 13, minute: 0)),
                priority: .medium
            ),
            CoachingRecommendation(
                category: .exercise,
                title: "Janela ideal para exercício",
                body: "Seu corpo está na temperatura ideal para treino. Exercícios agora maximizam desempenho e não interferem no sono.",
                scheduledTime: Calendar.current.date(from: DateComponents(hour: 17, minute: 0)),
                priority: .medium
            ),
            CoachingRecommendation(
                category: .sleep,
                title: "Inicie o ritual de sono",
                body: "Reduza a exposição a telas azuis e dim as luzes. Seu corpo precisa de 90 minutos de transição para dormir no horário ideal.",
                scheduledTime: Calendar.current.date(from: DateComponents(hour: 21, minute: 30)),
                priority: .high
            ),
            CoachingRecommendation(
                category: .cognitive,
                title: "Pico cognitivo",
                body: "Você está na janela de maior desempenho mental. Ideal para tarefas complexas, criativas ou de alta concentração.",
                scheduledTime: Calendar.current.date(from: DateComponents(hour: 10, minute: 0)),
                isCompleted: true,
                priority: .high
            )
        ]
    }
}

// MARK: - Enums

enum RecommendationCategory: String, Codable, CaseIterable {
    case light      = "light"
    case caffeine   = "caffeine"
    case exercise   = "exercise"
    case sleep      = "sleep"
    case cognitive  = "cognitive"
    case nutrition  = "nutrition"

    var label: String {
        switch self {
        case .light:     return "Luz"
        case .caffeine:  return "Cafeína"
        case .exercise:  return "Exercício"
        case .sleep:     return "Sono"
        case .cognitive: return "Cognição"
        case .nutrition: return "Nutrição"
        }
    }

    var systemImage: String {
        switch self {
        case .light:     return "sun.max.fill"
        case .caffeine:  return "cup.and.saucer.fill"
        case .exercise:  return "figure.run"
        case .sleep:     return "moon.zzz.fill"
        case .cognitive: return "brain.head.profile"
        case .nutrition: return "fork.knife"
        }
    }

    var color: String {
        switch self {
        case .light:     return "colorLight"
        case .caffeine:  return "colorCaffeine"
        case .exercise:  return "colorExercise"
        case .sleep:     return "colorSleep"
        case .cognitive: return "colorCognitive"
        case .nutrition: return "colorNutrition"
        }
    }
}

enum RecommendationPriority: String, Codable, CaseIterable {
    case low    = "low"
    case medium = "medium"
    case high   = "high"

    var label: String {
        switch self {
        case .low:    return "Baixa"
        case .medium: return "Média"
        case .high:   return "Alta"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high:   return 0
        case .medium: return 1
        case .low:    return 2
        }
    }
}
