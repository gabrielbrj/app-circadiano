// Views/Profile/ProfileFormView.swift
// Formulário de edição do perfil circadiano

import SwiftUI

struct ProfileFormView: View {

    @Bindable var viewModel: ProfileViewModel
    let onSave: (CircadianProfile) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                personalSection
                chronotypeSection
                caffeineExerciseSection
                notificationsSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .overlay {
                if viewModel.isSaving { LoadingView() }
            }
        }
    }

    // MARK: - Sections

    private var personalSection: some View {
        Section {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 20)
                TextField("Seu nome", text: $viewModel.name)
                    .accessibilityLabel("Nome completo")
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 20)
                DatePicker(
                    "Data de nascimento",
                    selection: $viewModel.birthDate,
                    in: ...Calendar.current.date(byAdding: .year, value: -13, to: Date())!,
                    displayedComponents: .date
                )
                .accessibilityLabel("Data de nascimento")
            }
        } header: {
            Text("Dados Pessoais")
        }
    }

    private var chronotypeSection: some View {
        Section {
            ForEach(Chronotype.allCases, id: \.self) { chronotype in
                HStack(spacing: 12) {
                    Text(chronotype.emoji)
                        .font(.title3)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(chronotype.label)
                            .font(.subheadline)
                            .foregroundStyle(Color.appPrimary)
                        Text(chronotype.description)
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryText)
                    }

                    Spacer()

                    if viewModel.selectedChronotype == chronotype {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appAccent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedChronotype = chronotype
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .accessibilityLabel("\(chronotype.label). \(chronotype.description)")
                .accessibilityAddTraits(viewModel.selectedChronotype == chronotype ? .isSelected : [])
            }
        } header: {
            Text("Cronotipo")
        } footer: {
            Text("Seu cronotipo é determinado geneticamente e define os horários naturais de sono e alerta")
                .font(.caption)
        }
    }

    private var caffeineExerciseSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(Color.appAccent)
                        .frame(width: 20)
                    Text("Corte a cafeína às \(viewModel.caffeineCutoffLabel)")
                    Spacer()
                }
                Slider(value: Binding(
                    get: { Double(viewModel.caffeineCutoffHour) },
                    set: { viewModel.caffeineCutoffHour = Int($0) }
                ), in: 10...20, step: 1)
                .tint(Color.appAccent)
                .accessibilityLabel("Hora de corte da cafeína: \(viewModel.caffeineCutoffHour) horas")
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.run")
                        .foregroundStyle(Color.appAccent)
                        .frame(width: 20)
                    Text("Exercício às \(viewModel.exerciseTimeLabel)")
                    Spacer()
                }
                Slider(value: Binding(
                    get: { Double(viewModel.exercisePreferenceHour) },
                    set: { viewModel.exercisePreferenceHour = Int($0) }
                ), in: 5...21, step: 1)
                .tint(Color.appSuccess)
                .accessibilityLabel("Hora preferida para exercício: \(viewModel.exercisePreferenceHour) horas")
            }
            .padding(.vertical, 4)
        } header: {
            Text("Hábitos")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $viewModel.lightExposureReminder) {
                HStack(spacing: 10) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(Color.appWarning)
                        .frame(width: 20)
                    Text("Lembretes de luz solar")
                }
            }
            .tint(Color.appAccent)
            .accessibilityLabel("Lembretes de exposição à luz solar")

            Toggle(isOn: $viewModel.smartAlarmEnabled) {
                HStack(spacing: 10) {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(Color.appAccent)
                        .frame(width: 20)
                    Text("Despertador inteligente")
                }
            }
            .tint(Color.appAccent)
            .accessibilityLabel("Despertador inteligente: acorda na fase de sono leve")

            if viewModel.smartAlarmEnabled {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(Color.appAccent)
                            .frame(width: 20)
                        Text("Janela: \(viewModel.smartAlarmWindowMinutes) minutos antes")
                    }
                    Slider(value: Binding(
                        get: { Double(viewModel.smartAlarmWindowMinutes) },
                        set: { viewModel.smartAlarmWindowMinutes = Int($0) }
                    ), in: 10...60, step: 5)
                    .tint(Color.appAccent)
                    .accessibilityLabel("Janela do despertador: \(viewModel.smartAlarmWindowMinutes) minutos")
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Notificações")
        } footer: {
            Text("O despertador inteligente acorda você na janela mais leve do sono, antes do horário definido")
                .font(.caption)
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
                onSave(viewModel.createNewProfile())
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            }
            .bold()
            .foregroundStyle(viewModel.isFormValid ? Color.appAccent : Color.appSecondaryText)
            .disabled(!viewModel.isFormValid)
            .accessibilityLabel("Salvar perfil")
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileFormView(viewModel: ProfileViewModel()) { _ in }
}
