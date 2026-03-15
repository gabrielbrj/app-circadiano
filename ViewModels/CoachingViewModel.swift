// ViewModels/CoachingViewModel.swift
// ViewModel para recomendações e coaching circadiano

import Foundation
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "CoachingVM")

@Observable
final class CoachingViewModel {

    var recommendations: [CoachingRecommendation] = []
    var selectedCategory: RecommendationCategory? = nil
    var isLoading = false
    var error: AppError?

    private let service: CoachingService

    init(service: CoachingService = CoachingService()) {
        self.service = service
    }

    // MARK: - Load

    func load(profile: CircadianProfile?, sleepEntries: [SleepEntry], score: CircadianScore?) async {
        isLoading = true
        defer { isLoading = false }

        guard let profile else {
            recommendations = CoachingRecommendation.sampleRecommendations
            return
        }

        recommendations = await service.generateDailyRecommendations(
            profile: profile,
            recentEntries: sleepEntries,
            currentScore: score
        )

        logger.info("Coaching carregado: \(self.recommendations.count) recomendações")
    }

    // MARK: - Actions

    func markAsCompleted(_ recommendation: CoachingRecommendation) {
        recommendation.isCompleted = true
        recommendation.completedAt = Date()

        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        logger.info("Recomendação concluída: \(recommendation.title)")
    }

    func toggleCompletion(_ recommendation: CoachingRecommendation) {
        if recommendation.isCompleted {
            recommendation.isCompleted = false
            recommendation.completedAt = nil
        } else {
            markAsCompleted(recommendation)
        }
    }

    // MARK: - Filtered

    var filteredRecommendations: [CoachingRecommendation] {
        guard let category = selectedCategory else {
            return recommendations.filter { !$0.isExpired }
        }
        return recommendations.filter { $0.category == category && !$0.isExpired }
    }

    var completedCount: Int {
        recommendations.filter { $0.isCompleted }.count
    }

    var completionProgress: Double {
        guard !recommendations.isEmpty else { return 0 }
        return Double(completedCount) / Double(recommendations.count)
    }

    var pendingHighPriority: [CoachingRecommendation] {
        recommendations.filter { $0.priority == .high && !$0.isCompleted }
    }
}
