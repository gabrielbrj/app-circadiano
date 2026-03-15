// Views/Profile/ProfileView.swift
// Tela de perfil do usuário, configurações e cronotipo

import SwiftUI
import SwiftData

struct ProfileView: View {

    @Query private var profiles: [CircadianProfile]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = ProfileViewModel()
    @State private var isEditing = false

    private var profile: CircadianProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                chronotypeSection
                settingsSection
                subscriptionSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $isEditing) {
            ProfileFormView(viewModel: viewModel) { savedProfile in
                if let existing = profile {
                    Task { await viewModel.save(to: existing) }
                    try? modelContext.save()
                } else {
                    let newProfile = viewModel.createNewProfile()
                    modelContext.insert(newProfile)
                    try? modelContext.save()
                }
            }
        }
        .onAppear {
            viewModel.load(from: profile)
        }
    }

    // MARK: - Sections

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Text(profile?.name.prefix(2).uppercased() ?? "?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appAccent)
            }

            VStack(spacing: 4) {
                Text(profile?.name.isEmpty == false ? profile!.name : "Configure seu perfil")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appPrimary)
                    .accessibilityAddTraits(.isHeader)

                if let profile {
                    Text("\(profile.chronotype.emoji) \(profile.chronotype.label) · \(viewModel.age) anos")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSecondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var chronotypeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Cronotipo", icon: "clock.arrow.circlepath")

            let chronotype = profile?.chronotype ?? .intermediate
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(chronotype.emoji)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chronotype.label)
                            .font(.headline)
                            .foregroundStyle(Color.appPrimary)
                        Text(chronotype.description)
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryText)
                    }
                }

                Divider().overlay(Color.appSeparator)

                HStack(spacing: 20) {
                    chronoStat(
                        label: "Dormir",
                        value: String(format: "%02d:00", chronotype.idealBedtimeHour)
                    )
                    chronoStat(
                        label: "Acordar",
                        value: String(format: "%02d:00", chronotype.idealWakeHour)
                    )
                    chronoStat(
                        label: "Cafeína até",
                        value: viewModel.caffeineCutoffLabel
                    )
                }
            }
            .padding(18)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Configurações", icon: "gearshape.fill")

            VStack(spacing: 0) {
                settingsRow(
                    icon: "bell.fill",
                    label: "Lembretes de luz",
                    value: profile?.lightExposureReminder == true ? "Ativo" : "Desativo"
                )
                Divider().padding(.leading, 56)
                settingsRow(
                    icon: "alarm.fill",
                    label: "Despertador inteligente",
                    value: profile?.smartAlarmEnabled == true ? "Ativo" : "Desativo"
                )
                Divider().padding(.leading, 56)
                settingsRow(
                    icon: "cup.and.saucer.fill",
                    label: "Limite de cafeína",
                    value: viewModel.caffeineCutoffLabel
                )
                Divider().padding(.leading, 56)
                settingsRow(
                    icon: "figure.run",
                    label: "Exercício preferido",
                    value: viewModel.exerciseTimeLabel
                )
            }
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Assinatura", icon: "crown.fill")

            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appWarning)
                    .frame(width: 40, height: 40)
                    .background(Color.appWarning.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile?.subscriptionTier == .premium ? "CircadiaCare Premium" : "Plano Gratuito")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.appPrimary)
                    Text(profile?.subscriptionTier == .premium
                         ? "Acesso completo a todas as funcionalidades"
                         : "Upgrade para análises avançadas e relatórios")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryText)
                }

                Spacer()

                if profile?.subscriptionTier != .premium {
                    Text("Ver planos")
                        .font(.caption.bold())
                        .foregroundStyle(Color.appAccent)
                }
            }
            .padding(16)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appWarning.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(profile == nil ? "Configurar" : "Editar") {
                viewModel.load(from: profile)
                isEditing = true
            }
            .foregroundStyle(Color.appAccent)
            .accessibilityLabel(profile == nil ? "Configurar perfil" : "Editar perfil")
        }
    }

    // MARK: - Helpers

    private func chronoStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(Color.appAccent)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(label): \(value)")
    }

    private func settingsRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appAccent)
                .frame(width: 28, height: 28)
                .background(Color.appAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 7))
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.appSecondaryText)
        }
        .padding(16)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: [CircadianProfile.self, SleepEntry.self], inMemory: true)
}
