// Views/Coaching/CoachingView.swift
// Tela de coaching circadiano com recomendações personalizadas

import SwiftUI
import SwiftData

struct CoachingView: View {

    @Query(sort: \SleepEntry.bedtime, order: .reverse) private var sleepEntries: [SleepEntry]
    @Query private var profiles: [CircadianProfile]

    @State private var viewModel = CoachingViewModel()

    private var profile: CircadianProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                progressSection
                categoryFilterSection
                recommendationsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Coaching")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.load(
                profile: profile,
                sleepEntries: sleepEntries,
                score: nil
            )
        }
        .overlay {
            if viewModel.isLoading { LoadingView() }
        }
        .alert("Erro", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }

    // MARK: - Sections

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Progresso Hoje", icon: "checkmark.seal.fill")

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(viewModel.completedCount) de \(viewModel.recommendations.count)")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appPrimary)
                    Text("recomendações concluídas")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryText)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.appSeparator, lineWidth: 6)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: viewModel.completionProgress)
                        .stroke(Color.appSuccess, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 56, height: 56)
                        .animation(.spring(duration: 0.6), value: viewModel.completionProgress)
                    Text("\(Int(viewModel.completionProgress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appPrimary)
                }
            }

            ProgressView(value: viewModel.completionProgress)
                .tint(Color.appSuccess)
                .scaleEffect(x: 1, y: 1.5)
        }
        .padding(18)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    label: "Todos",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(RecommendationCategory.allCases, id: \.self) { category in
                    FilterChip(
                        label: category.label,
                        icon: category.systemImage,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recomendações do Dia", icon: "list.bullet.clipboard")

            if viewModel.filteredRecommendations.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle.fill",
                    title: "Tudo concluído!",
                    message: "Você completou todas as recomendações desta categoria"
                )
            } else {
                ForEach(viewModel.filteredRecommendations, id: \.id) { rec in
                    NavigationLink(destination: CoachingDetailView(recommendation: rec)) {
                        RecommendationCard(
                            recommendation: rec,
                            onToggle: { viewModel.toggleCompletion(rec) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : Color.appPrimary)
            .background(isSelected ? Color.appAccent : Color.appCardBackground, in: Capsule())
            .overlay(
                Capsule().stroke(isSelected ? Color.clear : Color.appSeparator, lineWidth: 1)
            )
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: CoachingRecommendation
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: recommendation.isCompleted
                      ? "checkmark.circle.fill"
                      : "circle")
                    .font(.title3)
                    .foregroundStyle(recommendation.isCompleted
                                     ? Color.appSuccess
                                     : Color.appSeparator)
            }
            .accessibilityLabel(recommendation.isCompleted ? "Marcar como pendente" : "Marcar como concluído")

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: recommendation.category.systemImage)
                        .font(.caption)
                        .foregroundStyle(Color.appAccent)
                    Text(recommendation.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(recommendation.isCompleted
                                         ? Color.appSecondaryText
                                         : Color.appPrimary)
                        .strikethrough(recommendation.isCompleted)
                }

                if let time = recommendation.scheduledTime {
                    Text(time.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryText)
                }
            }

            Spacer()

            if recommendation.priority == .high && !recommendation.isCompleted {
                Circle()
                    .fill(Color.appError)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("Alta prioridade")
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(Color.appSecondaryText)
        }
        .padding(16)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(recommendation.isCompleted ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: recommendation.isCompleted)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(recommendation.title). \(recommendation.isCompleted ? "Concluído" : "Pendente")")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CoachingView()
    }
    .modelContainer(for: [
        SleepEntry.self, CircadianProfile.self,
        CoachingRecommendation.self, CircadianScore.self
    ], inMemory: true)
}
