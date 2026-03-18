// Views/Profile/OnboardingView.swift
// Tela de onboarding para novos usuários

import SwiftUI
import UIKit
import SwiftData

struct OnboardingView: View {

    @Binding var isCompleted: Bool
    @Environment(\.modelContext) private var modelContext

    @State private var currentPage = 0
    @State private var viewModel = ProfileViewModel()

    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                chronotypePage.tag(1)
                settingsPage.tag(2)
                readyPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            bottomBar
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appAccent)
            }

            VStack(spacing: 12) {
                Text("CircadiaCare")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Sincronize seu relógio biológico.\nDurma melhor. Pense com mais clareza.")
                    .font(.body)
                    .foregroundStyle(Color.appSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                onboardingFeature(icon: "bed.double.fill",
                                  color: .appAccent,
                                  text: "Análise científica do seu sono")
                onboardingFeature(icon: "brain.head.profile",
                                  color: .appSuccess,
                                  text: "Coaching circadiano personalizado")
                onboardingFeature(icon: "chart.line.uptrend.xyaxis",
                                  color: .appWarning,
                                  text: "Score diário de alinhamento")
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var chronotypePage: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Qual é o seu cronotipo?")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Isso define seus horários biológicos ideais")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryText)
            }

            VStack(spacing: 10) {
                ForEach(Chronotype.allCases, id: \.self) { chronotype in
                    Button {
                        viewModel.selectedChronotype = chronotype
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        HStack(spacing: 14) {
                            Text(chronotype.emoji)
                                .font(.title2)
                                .frame(width: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(chronotype.label)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.appPrimary)
                                Text(chronotype.description)
                                    .font(.caption)
                                    .foregroundStyle(Color.appSecondaryText)
                                    .lineLimit(2)
                            }
                            Spacer()
                            if viewModel.selectedChronotype == chronotype {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .padding(14)
                        .background(
                            viewModel.selectedChronotype == chronotype
                                ? Color.appAccent.opacity(0.1)
                                : Color.appCardBackground,
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(viewModel.selectedChronotype == chronotype
                                        ? Color.appAccent
                                        : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .accessibilityLabel("\(chronotype.label). \(chronotype.description)")
                    .accessibilityAddTraits(viewModel.selectedChronotype == chronotype ? .isSelected : [])
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var settingsPage: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Personalize seu coaching")
                    .font(.title2.bold())
                    .foregroundStyle(Color.appPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Ajuste para sua rotina")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryText)
            }

            VStack(spacing: 16) {
                TextField("Seu nome", text: $viewModel.name)
                    .padding(14)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Nome completo")

                VStack(spacing: 8) {
                    HStack {
                        Text("☕ Corte cafeína às \(viewModel.caffeineCutoffLabel)")
                            .font(.subheadline)
                            .foregroundStyle(Color.appPrimary)
                        Spacer()
                    }
                    Slider(value: Binding(
                        get: { Double(viewModel.caffeineCutoffHour) },
                        set: { viewModel.caffeineCutoffHour = Int($0) }
                    ), in: 10...20, step: 1)
                    .tint(Color.appAccent)
                }
                .padding(14)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Toggle(isOn: $viewModel.lightExposureReminder) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(Color.appAccent)
                        Text("Ativar lembretes circadianos")
                            .font(.subheadline)
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                .tint(Color.appAccent)
                .padding(14)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var readyPage: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appSuccess.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.appSuccess)
            }

            VStack(spacing: 12) {
                Text("Tudo pronto!")
                    .font(.title.bold())
                    .foregroundStyle(Color.appPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Seu perfil circadiano foi criado.\nComece registrando seu sono hoje à noite.")
                    .font(.body)
                    .foregroundStyle(Color.appSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? Color.appAccent : Color.appSeparator)
                        .frame(width: currentPage == index ? 20 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }

            Button {
                if currentPage < totalPages - 1 {
                    withAnimation { currentPage += 1 }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(currentPage == totalPages - 1 ? "Começar" : "Continuar")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appAccent, in: RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel(currentPage == totalPages - 1 ? "Começar a usar o app" : "Continuar para próxima etapa")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 12)
    }

    // MARK: - Actions

    private func completeOnboarding() {
        let profile = viewModel.createNewProfile()
        modelContext.insert(profile)
        try? modelContext.save()
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation { isCompleted = true }
    }

    private func onboardingFeature(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isCompleted: .constant(false))
        .modelContainer(for: CircadianProfile.self, inMemory: true)
}
