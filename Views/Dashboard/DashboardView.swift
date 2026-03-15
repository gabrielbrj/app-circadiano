// Views/Dashboard/DashboardView.swift
// Tela principal com score circadiano e resumo do dia

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Query(sort: \SleepEntry.bedtime, order: .reverse) private var sleepEntries: [SleepEntry]
    @Query private var profiles: [CircadianProfile]

    @State private var viewModel = DashboardViewModel()

    private var profile: CircadianProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                scoreCardSection
                peakWindowSection
                weeklyChartSection
                quickStatsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.load(sleepEntries: sleepEntries, profile: profile)
        }
        .onChange(of: sleepEntries.count) {
            Task { await viewModel.load(sleepEntries: sleepEntries, profile: profile) }
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

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greetingMessage)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryText)
            }
            Spacer()
            CircadianClockView(score: viewModel.todayScore?.overallScore ?? 0)
                .frame(width: 52, height: 52)
        }
        .padding(.top, 8)
    }

    private var scoreCardSection: some View {
        CircadianScoreCard(
            score: viewModel.todayScore,
            changeText: viewModel.scoreChangeText
        )
        .animation(.spring(duration: 0.5), value: viewModel.todayScore?.overallScore)
    }

    private var peakWindowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Janelas de Desempenho", icon: "brain.head.profile")
            if viewModel.peakWindows.isEmpty {
                EmptyStateView(
                    icon: "brain.head.profile",
                    title: "Configure seu perfil",
                    message: "Complete seu perfil para ver janelas de desempenho"
                )
            } else {
                ForEach(viewModel.peakWindows, id: \.label) { window in
                    PeakWindowRow(window: window, isActive: isWindowActive(window))
                }
            }
        }
    }

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Score da Semana", icon: "chart.line.uptrend.xyaxis")
            WeeklyScoreChart(scores: viewModel.weeklyScores)
                .frame(height: 120)
        }
    }

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Resumo de Ontem", icon: "moon.stars.fill")
            if let lastEntry = viewModel.lastSleepEntry {
                SleepSummaryCard(entry: lastEntry)
            } else {
                EmptyStateView(
                    icon: "bed.double",
                    title: "Sem registros",
                    message: "Registre seu sono para ver análises"
                )
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("CircadiaCare")
                .font(.headline)
                .foregroundStyle(Color.appAccent)
        }
    }

    // MARK: - Helpers

    private func isWindowActive(_ window: TimeWindow) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= window.startHour && hour < window.endHour
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: [
        SleepEntry.self, CircadianProfile.self,
        CircadianScore.self, CoachingRecommendation.self
    ], inMemory: true)
}
