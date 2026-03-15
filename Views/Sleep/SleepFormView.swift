// Views/Sleep/SleepFormView.swift
// Formulário de registro de sono com importação HealthKit

import SwiftUI

struct SleepFormView: View {

    @Bindable var viewModel: SleepViewModel
    let onSave: (SleepEntry) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    healthKitBanner
                    timesSection
                    qualitySection
                    stagesSection
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Registrar Sono")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .overlay {
                if viewModel.isLoading { LoadingView() }
            }
            .alert("Erro", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }

    // MARK: - Sections

    private var healthKitBanner: some View {
        Button {
            Task { await viewModel.importFromHealthKit() }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.appError, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Importar do Apple Watch")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.appPrimary)
                    Text("Preenche automaticamente com seus dados de saúde")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryText)
            }
            .padding(16)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel("Importar dados do Apple Watch via HealthKit")
        .accessibilityHint("Preenche automaticamente os campos com seus dados de sono")
    }

    private var timesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Horários", icon: "clock.fill")

            VStack(spacing: 0) {
                DatePicker(
                    "Hora de dormir",
                    selection: $viewModel.bedtime,
                    displayedComponents: [.hourAndMinute]
                )
                .padding(16)
                .accessibilityLabel("Hora que foi dormir")

                Divider().padding(.leading, 16)

                DatePicker(
                    "Hora de acordar",
                    selection: $viewModel.wakeTime,
                    displayedComponents: [.hourAndMinute]
                )
                .padding(16)
                .accessibilityLabel("Hora que acordou")
            }
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if viewModel.wakeTime > viewModel.bedtime {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(Color.appAccent)
                    Text("Duração total: \(viewModel.formattedDuration)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appAccent)
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Qualidade Subjetiva", icon: "star.fill")

            VStack(spacing: 12) {
                HStack {
                    Text("Como você se sente?")
                        .font(.subheadline)
                        .foregroundStyle(Color.appPrimary)
                    Spacer()
                    Text(viewModel.qualityLabel)
                        .font(.subheadline.bold())
                        .foregroundStyle(viewModel.qualityColor)
                        .animation(.easeInOut, value: viewModel.qualityLabel)
                }

                Slider(
                    value: Binding(
                        get: { Double(viewModel.sleepQuality) },
                        set: { viewModel.sleepQuality = Int($0) }
                    ),
                    in: 1...10,
                    step: 1
                )
                .tint(viewModel.qualityColor)
                .accessibilityLabel("Qualidade do sono: \(viewModel.sleepQuality) de 10")
                .accessibilityValue(viewModel.qualityLabel)

                HStack {
                    Text("Péssimo")
                    Spacer()
                    Text("Excelente")
                }
                .font(.caption)
                .foregroundStyle(Color.appSecondaryText)
            }
            .padding(16)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var stagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Fases (opcional)", icon: "waveform.path.ecg")

            VStack(spacing: 0) {
                SleepStageStepper(
                    label: "Sono Profundo",
                    icon: "moon.fill",
                    color: .appAccent,
                    minutes: $viewModel.deepSleepMinutes
                )
                Divider().padding(.leading, 16)
                SleepStageStepper(
                    label: "Sono REM",
                    icon: "brain.head.profile",
                    color: .appSuccess,
                    minutes: $viewModel.remSleepMinutes
                )
                Divider().padding(.leading, 16)
                SleepStageStepper(
                    label: "Sono Leve",
                    icon: "moon.haze.fill",
                    color: .appWarning,
                    minutes: $viewModel.lightSleepMinutes
                )
                Divider().padding(.leading, 16)
                SleepStageStepper(
                    label: "Acordado",
                    icon: "eye.fill",
                    color: .appError,
                    minutes: $viewModel.awakeMinutes
                )
            }
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Anotações", icon: "note.text")

            TextField("Como foi seu sono? O que pode ter influenciado?", text: $viewModel.notes, axis: .vertical)
                .padding(16)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .lineLimit(3...6)
                .accessibilityLabel("Anotações sobre seu sono")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") { dismiss() }
                .foregroundStyle(Color.appSecondaryText)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Salvar") {
                let entry = viewModel.buildEntry()
                onSave(entry)
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
                dismiss()
            }
            .bold()
            .foregroundStyle(viewModel.isFormValid ? Color.appAccent : Color.appSecondaryText)
            .disabled(!viewModel.isFormValid)
            .accessibilityLabel("Salvar registro de sono")
            .accessibilityHint(viewModel.isFormValid ? "" : "O horário de acordar deve ser após dormir")
        }
    }
}

// MARK: - Stage Stepper

struct SleepStageStepper: View {
    let label: String
    let icon: String
    let color: Color
    @Binding var minutes: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if minutes >= 10 { minutes -= 10 }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(minutes > 0 ? color : Color.appSeparator)
                }
                .accessibilityLabel("Diminuir \(label)")
                .disabled(minutes == 0)

                Text("\(minutes)m")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 44)

                Button {
                    minutes += 10
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(color)
                }
                .accessibilityLabel("Aumentar \(label)")
            }
        }
        .padding(16)
    }
}

// MARK: - Preview

#Preview {
    SleepFormView(viewModel: SleepViewModel()) { _ in }
}
