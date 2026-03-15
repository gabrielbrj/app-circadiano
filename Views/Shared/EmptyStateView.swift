// Views/Shared/EmptyStateView.swift
// View de estado vazio reutilizável em todo o app

import SwiftUI

struct EmptyStateView: View {

    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color.appAccent.opacity(0.6))
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.appAccent, in: Capsule())
                }
                .accessibilityLabel(actionTitle)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        EmptyStateView(
            icon: "bed.double.fill",
            title: "Nenhum registro de sono",
            message: "Toque em + para registrar sua primeira noite de sono",
            actionTitle: "Registrar agora",
            action: { }
        )

        EmptyStateView(
            icon: "brain.head.profile",
            title: "Configure seu perfil",
            message: "Complete seu perfil para ver recomendações personalizadas"
        )
    }
    .background(Color.appBackground)
}
