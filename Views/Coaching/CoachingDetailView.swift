// Views/Coaching/CoachingDetailView.swift
// Detalhe de uma recomendação circadiana com contexto científico

import SwiftUI
import UIKit

struct CoachingDetailView: View {

    let recommendation: CoachingRecommendation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                bodySection
                scienceSection
                actionSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(recommendation.category.label)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: recommendation.category.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.appAccent, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.title3.bold())
                        .foregroundStyle(Color.appPrimary)
                        .accessibilityAddTraits(.isHeader)

                    HStack(spacing: 8) {
                        PriorityBadge(priority: recommendation.priority)

                        if let time = recommendation.scheduledTime {
                            Label(time.formatted(.dateTime.hour().minute()), systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(Color.appSecondaryText)
                        }
                    }
                }
            }
            .padding(.top, 8)

            if recommendation.isCompleted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appSuccess)
                    Text("Concluído\(recommendation.completedAt != nil ? " às \(recommendation.completedAt!.formatted(.dateTime.hour().minute()))" : "")")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSuccess)
                }
                .padding(12)
                .background(Color.appSuccess.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "O que fazer", icon: "list.bullet")
            Text(recommendation.body)
                .font(.body)
                .foregroundStyle(Color.appPrimary)
                .lineSpacing(4)
        }
        .padding(18)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var scienceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Por quê isso importa", icon: "flask.fill")
            Text(scienceText(for: recommendation.category))
                .font(.body)
                .foregroundStyle(Color.appPrimary)
                .lineSpacing(4)
        }
        .padding(18)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            if !recommendation.isCompleted {
                Button {
                    recommendation.isCompleted = true
                    recommendation.completedAt = Date()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Label("Marcar como Concluído", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appAccent, in: RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Marcar recomendação como concluída")
                .accessibilityHint("Registra que você realizou esta recomendação")
            }
        }
    }

    // MARK: - Science Content

    private func scienceText(for category: RecommendationCategory) -> String {
        switch category {
        case .light:
            return "O núcleo supraquiasmático (NSQ), seu relógio biológico mestre, depende de sinais de luz para se sincronizar com o ciclo de 24h. A melanopsina nas células ganglionares da retina é mais sensível à luz azul (480nm), transmitindo sinais diretamente ao NSQ. Essa sincronização diária controla a liberação de mais de 100 hormônios ao longo do dia."
        case .caffeine:
            return "A cafeína bloqueia os receptores de adenosina, um neurotransmissor que acumula 'pressão de sono' ao longo do dia. Com meia-vida de 5-6 horas, uma dose às 15h ainda tem 50% de efeito às 21h. Isso reduz o sono de ondas lentas (profundo) em até 20%, comprometendo a restauração física e consolidação de memória."
        case .exercise:
            return "A temperatura corporal central segue um ritmo circadiano, atingindo seu pico entre 16h-18h. Exercitar-se durante esse pico maximiza força, velocidade e VO2 máximo em 10-20%. Exercícios matinais podem avançar a fase circadiana (ajudam notívagos), enquanto exercícios noturnos após as 21h podem atrasar o início do sono."
        case .sleep:
            return "A melatonina começa a ser liberada 2-3h antes do horário habitual de sono, sinalizando ao corpo para reduzir temperatura e preparar para o descanso. Luz azul de telas suprime essa liberação. Manter temperatura ambiente entre 18-20°C facilita a queda de 1-2°C na temperatura corporal necessária para adormecer."
        case .cognitive:
            return "O cortisol atinge seu pico natural 30-45 minutos após acordar, seguido de um segundo pico de alerta cognitivo 2-4h depois. Isso coincide com a temperatura corporal em ascensão, resultando na janela de maior velocidade de processamento, memória de trabalho e capacidade de tomada de decisão do dia."
        case .nutrition:
            return "O sistema digestivo também possui relógios periféricos sincronizados com o ritmo central. Refeições no momento errado — especialmente à noite — podem desalinhar esses relógios periféricos, afetando metabolismo de glicose, sensibilidade à insulina e microbioma intestinal. Concentrar calorias nas primeiras 8-10h do dia otimiza o metabolismo circadiano."
        }
    }
}

// MARK: - Priority Badge

struct PriorityBadge: View {
    let priority: RecommendationPriority

    var body: some View {
        Text(priority.label)
            .font(.caption2.bold())
            .foregroundStyle(badgeColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.15), in: Capsule())
    }

    private var badgeColor: Color {
        switch priority {
        case .high:   return .appError
        case .medium: return .appWarning
        case .low:    return .appSuccess
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CoachingDetailView(recommendation: CoachingRecommendation.sampleRecommendations[0])
    }
}
