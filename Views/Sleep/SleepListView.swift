// Views/Sleep/SleepListView.swift
// Lista de registros de sono com histórico e estatísticas

import SwiftUI
import SwiftData

struct SleepListView: View {

    @Query(sort: \SleepEntry.bedtime, order: .reverse) private var entries: [SleepEntry]
    @Query private var profiles: [CircadianProfile]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = SleepViewModel()
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: SleepEntry?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                sleepStatsHeader
                entriesList
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Sono")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showingForm) {
            SleepFormView(viewModel: viewModel) { entry in
                saveEntry(entry)
            }
        }
        .sheet(item: $viewModel.selectedEntry) { entry in
            SleepDetailView(entry: entry)
        }
        .alert("Excluir registro?", isPresented: $showingDeleteAlert) {
            Button("Excluir", role: .destructive) {
                if let entry = entryToDelete { deleteEntry(entry) }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Esta ação não pode ser desfeita.")
        }
        .overlay {
            if viewModel.isLoading { LoadingView() }
        }
    }

    // MARK: - Sections

    private var sleepStatsHeader: some View {
        VStack(spacing: 12) {
            if entries.isEmpty {
                EmptyStateView(
                    icon: "bed.double.fill",
                    title: "Nenhum registro de sono",
                    message: "Toque em + para registrar sua primeira noite"
                )
                .padding(.top, 40)
            } else {
                SleepWeeklyStatsCard(entries: Array(entries.prefix(7)))
            }
        }
    }

    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !entries.isEmpty {
                SectionHeader(title: "Histórico", icon: "calendar")

                ForEach(entries) { entry in
                    SleepEntryRow(entry: entry)
                        .onTapGesture {
                            let feedback = UIImpactFeedbackGenerator(style: .light)
                            feedback.impactOccurred()
                            viewModel.selectedEntry = entry
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                entryToDelete = entry
                                showingDeleteAlert = true
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                        .accessibilityHint("Toque para ver detalhes. Deslize para excluir.")
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.resetForm()
                viewModel.showingForm = true
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.impactOccurred()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appAccent)
            }
            .accessibilityLabel("Registrar nova noite de sono")
        }
    }

    // MARK: - Actions

    private func saveEntry(_ entry: SleepEntry) {
        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            viewModel.error = .saveFailed(error.localizedDescription)
        }
    }

    private func deleteEntry(_ entry: SleepEntry) {
        modelContext.delete(entry)
        do {
            try modelContext.save()
        } catch {
            viewModel.error = .deleteFailed(error.localizedDescription)
        }
    }
}

// MARK: - Entry Row

struct SleepEntryRow: View {
    let entry: SleepEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(entry.bedtime.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2.uppercased())
                    .foregroundStyle(Color.appSecondaryText)
                Text(entry.bedtime.formatted(.dateTime.day()))
                    .font(.title3.bold())
                    .foregroundStyle(Color.appPrimary)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.bedtime.formatted(.dateTime.hour().minute())) → \(entry.wakeTime.formatted(.dateTime.hour().minute()))")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.appPrimary)

                HStack(spacing: 8) {
                    Label(String(format: "%.1fh", entry.totalSleepHours), systemImage: "clock")
                    Label(entry.qualityLabel, systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundStyle(Color.appSecondaryText)
            }

            Spacer()

            QualityBadge(score: entry.sleepQualityScore)
        }
        .padding(16)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Quality Badge

struct QualityBadge: View {
    let score: Int

    var body: some View {
        Text("\(score)")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(badgeColor, in: Circle())
            .accessibilityLabel("Qualidade do sono: \(score) de 10")
    }

    private var badgeColor: Color {
        switch score {
        case 8...10: return .appSuccess
        case 6...7:  return .appWarning
        default:     return .appError
        }
    }
}

// MARK: - Weekly Stats Card

struct SleepWeeklyStatsCard: View {
    let entries: [SleepEntry]

    private var avgDuration: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map(\.totalSleepHours).reduce(0, +) / Double(entries.count)
    }

    private var avgQuality: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { Double($0.sleepQualityScore) }.reduce(0, +) / Double(entries.count)
    }

    private var avgEfficiency: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map(\.sleepEfficiency).reduce(0, +) / Double(entries.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Média dos Últimos 7 Dias", icon: "chart.bar.fill")

            HStack(spacing: 0) {
                weekStat(
                    value: String(format: "%.1f", avgDuration),
                    unit: "h",
                    label: "Duração",
                    color: .appAccent
                )
                Divider().frame(height: 44).overlay(Color.appSeparator)
                weekStat(
                    value: String(format: "%.1f", avgQuality),
                    unit: "/10",
                    label: "Qualidade",
                    color: .appSuccess
                )
                Divider().frame(height: 44).overlay(Color.appSeparator)
                weekStat(
                    value: String(format: "%.0f", avgEfficiency),
                    unit: "%",
                    label: "Eficiência",
                    color: .appWarning
                )
            }
        }
        .padding(18)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func weekStat(value: String, unit: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SleepListView()
    }
    .modelContainer(for: [SleepEntry.self, CircadianProfile.self], inMemory: true)
}
