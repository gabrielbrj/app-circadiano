// Views/Shared/LoadingView.swift
// View de carregamento com overlay semitransparente

import SwiftUI

struct LoadingView: View {

    var message: String = "Carregando..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.2)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        }
        .accessibilityLabel(message)
        .accessibilityAddTraits(.updatesFrequently)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Inline Loading (para listas)

struct InlineLoadingView: View {

    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.appAccent)
            Text("Carregando...")
                .font(.subheadline)
                .foregroundStyle(Color.appSecondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Carregando dados")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        LoadingView(message: "Calculando score circadiano...")
    }
}
