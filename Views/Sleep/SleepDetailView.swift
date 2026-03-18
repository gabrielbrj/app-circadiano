// Views/Sleep/SleepDetailView.swift
// Detalhes completos de uma noite de sono

import SwiftUI

struct SleepDetailView: View {

    let entry: SleepEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    timelineSection
                    stagesSection
                    heartRateSection
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(entry.bedtime.formatted(.dateTime.month(.wide).day()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    // MARK: - Sections

    private var timelineSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dormiu")
                        .font(.caption).textCase(.uppercase)
                        .foregroundStyle(Color.appSecondaryText)
                    Text(entry.bedtime.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appPrimary)
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appAccent)
                    Text(String(format: "%.1fh", entry.totalSleepHours))
                        .font(.headline)
                        .foregroundStyle(Color.appAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Acordou")
                        .font(.caption).textCase(.uppercase)
                        .foregroundStyle(Color.appSecondaryText)
                    Text(entry.wakeTime.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .padding(20)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            HStack(spacing: 12) {
                DetailMetricCard(
                    icon: "star.fill",
                    value: "\(entry.sleepQualityScore)/10",
                    label: "Qualidade",
                    color: .appWarning
                )
                DetailMetricCard(
                    icon: "percent",
                    value: "\(Int(entry.sleepEfficiency))%",
                    label: "Eficiência",
                    color: .appAccent
                )
            }
        }
    }

    private var stagesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Fases do Sono", icon: "waveform.path.ecg")

            VStack(spacing: 10) {
                SleepStageRow(
                    stage: "Sono Profundo",
                    minutes: entry.deepSleepMinutes,
                    total: entry.totalSleepMinutes,
                    color: .appAccent,
                    icon: "moon.fill",
                    description: "Restauração física e consolidação de memória"
                )
                SleepStageRow(
                    stage: "Sono REM",
                    minutes: entry.remSleepMinutes,
                    total: entry.totalSleepMinutes,
                    color: .appSuccess,
                    icon: "brain.head.profile",
                    description: "Processamento emocional e criatividade"
                )
                SleepStageRow(
                    stage: "Sono Leve",
                    minutes: entry.lightSleepMinutes,
                    total: entry.totalSleepMinutes,
                    color: .appWarning,
                    icon: "moon.haze.fill",
                    description: "Transição e preparação para fases profundas"
                )
                SleepStageRow(
                    stage: "Acordado",
                    minutes: entry.awakeMinutes,
                    total: entry.totalSleepMinutes,
                    color: .appError,
                    icon: "eye.fill",
                    description: "Fragmentação do sono"
                )
            }
        }
        .padding(18)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var heartRateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Frequência Cardíaca", icon: "heart.fill")

            HStack(spacing: 0) {
                heartRateStat(
                    label: "Média",
                    value: "\(Int(entry.heartRateAvg))",
                    unit: "bpm",
                    color: .appAccent
                )
                Divider().frame(height: 44).overlay(Color.appSeparator)
                heartRateStat(
                    label: "Mínima",
                    value: "\(Int(entry.heartRateMin))",
                    unit: "bpm",
                    color: .appSuccess
                )
            }
        }
        .padding(18)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var notesSection: some View {
        if !entry.notes.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Anotações", icon: "note.text")
                Text(entry.notes)
                    .font(.body)
                    .foregroundStyle(Color.appPrimary)
            }
            .padding(18)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private func heartRateStat(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
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
        .accessibilityLabel("\(label): \(value) \(unit)")
    }
}

// MARK: - Supporting Views

struct SleepStageRow: View {
    let stage: String
    let minutes: Int
    let total: Int
    let color: Color
    let icon: String
    let description: String

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(minutes) / Double(total)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                    .frame(width: 16)
                Text(stage)
                    .font(.subheadline)
                    .foregroundStyle(Color.appPrimary)
                Spacer()
                Text(Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes])))
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.appPrimary)
                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * percentage, height: 6)
                        .animation(.spring(duration: 0.8), value: percentage)
                }
            }
            .frame(height: 6)
        }
        .accessibilityLabel("\(stage): \(minutes) minutos, \(Int(percentage * 100)) por cento")
    }
}

struct DetailMetricCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundStyle(Color.appPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Preview

#Preview {
    SleepDetailView(entry: SleepEntry.sampleEntries[0])
}
