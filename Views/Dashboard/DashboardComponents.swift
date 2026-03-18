// Views/Dashboard/DashboardComponents.swift
// Componentes visuais do Dashboard: Score Card, Gráfico, Relógio Circadiano

import SwiftUI

// MARK: - Circadian Score Card

struct CircadianScoreCard: View {

    let score: CircadianScore?
    let changeText: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Score Circadiano")
                        .font(.caption).textCase(.uppercase)
                        .foregroundStyle(Color.appSecondaryText)
                        .accessibilityLabel("Score de alinhamento circadiano de hoje")

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(score?.overallScore ?? 0))")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor)
                            .contentTransition(.numericText())
                        Text("/100")
                            .font(.title3)
                            .foregroundStyle(Color.appSecondaryText)
                    }

                    Text(score?.scoreLabel ?? "--")
                        .font(.subheadline.bold())
                        .foregroundStyle(scoreColor)
                }

                Spacer()

                ScoreArcView(score: score?.overallScore ?? 0)
                    .frame(width: 90, height: 90)
                    .accessibilityLabel("Arco de score: \(Int(score?.overallScore ?? 0)) de 100")
            }
            .padding(20)

            Divider().overlay(Color.appSeparator)

            HStack {
                Image(systemName: score?.trendIsPositive ?? true ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                    .foregroundStyle(score?.trendIsPositive ?? true ? Color.appSuccess : Color.appError)
                Text(changeText)
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
                Spacer()
                Text(score?.scoreEmoji ?? "")
                    .font(.title3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var scoreColor: Color {
        let s = score?.overallScore ?? 0
        if s >= 80 { return .appSuccess }
        if s >= 60 { return .appWarning }
        return .appError
    }
}

// MARK: - Score Arc

struct ScoreArcView: View {
    let score: Double
    @State private var animatedScore: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appSeparator, lineWidth: 8)

            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(
                        colors: [.appError, .appWarning, .appSuccess],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(score))")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appPrimary)
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.2)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { _, new in
            withAnimation(.spring(duration: 0.8)) {
                animatedScore = new
            }
        }
    }
}

// MARK: - Circadian Clock

struct CircadianClockView: View {
    let score: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appAccent.opacity(0.15))

            Image(systemName: "moon.stars.fill")
                .font(.title3)
                .foregroundStyle(Color.appAccent)
        }
    }
}

// MARK: - Weekly Score Chart (simplified)

struct WeeklyScoreChart: View {
    let scores: [CircadianScore]

    var body: some View {
        GeometryReader { geo in
            let maxScore = scores.map(\.overallScore).max() ?? 100
            let minScore = max((scores.map(\.overallScore).min() ?? 0) - 10, 0)
            let range = maxScore - minScore

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(scores, id: \.id) { score in
                    VStack(spacing: 4) {
                        Spacer(minLength: 0)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(barColor(for: score.overallScore))
                            .frame(
                                height: range > 0
                                    ? (score.overallScore - minScore) / range * (geo.size.height - 28)
                                    : geo.size.height * 0.5
                            )
                            .animation(.spring(duration: 0.6).delay(0.05 * Double(scores.firstIndex(where: { $0.id == score.id }) ?? 0)), value: score.overallScore)

                        Text(score.date.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 10))
                            .foregroundStyle(Color.appSecondaryText)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func barColor(for score: Double) -> Color {
        if score >= 80 { return .appSuccess }
        if score >= 60 { return .appWarning }
        return .appError
    }
}

// MARK: - Peak Window Row

struct PeakWindowRow: View {
    let window: TimeWindow
    let isActive: Bool

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.appAccent : Color.appSeparator)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(window.label)
                    .font(.subheadline.bold())
                    .foregroundStyle(isActive ? Color.appAccent : Color.appPrimary)
                Text(window.formattedRange)
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
            }

            Spacer()

            if isActive {
                Text("AGORA")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appAccent, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isActive ? Color.appAccent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .accessibilityLabel("\(window.label): \(window.formattedRange)\(isActive ? ", ativo agora" : "")")
    }
}

// MARK: - Sleep Summary Card

struct SleepSummaryCard: View {
    let entry: SleepEntry

    var body: some View {
        HStack(spacing: 0) {
            statColumn(
                value: String(format: "%.1f", entry.totalSleepHours),
                unit: "h",
                label: "Duração",
                icon: "clock.fill"
            )
            Divider().frame(height: 50).overlay(Color.appSeparator)
            statColumn(
                value: "\(entry.sleepQualityScore)",
                unit: "/10",
                label: "Qualidade",
                icon: "star.fill"
            )
            Divider().frame(height: 50).overlay(Color.appSeparator)
            statColumn(
                value: "\(Int(entry.sleepEfficiency))",
                unit: "%",
                label: "Eficiência",
                icon: "percent"
            )
        }
        .padding(.vertical, 16)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statColumn(value: String, unit: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appPrimary)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(label): \(value)\(unit)")
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appAccent)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appPrimary)
        }
        .accessibilityAddTraits(.isHeader)
    }
}
