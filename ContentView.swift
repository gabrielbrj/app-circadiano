// ContentView.swift
// View raiz com TabView e NavigationStack principal

import SwiftUI
import SwiftData

struct ContentView: View {

    @State private var selectedTab: AppTab = .dashboard
    @State private var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "onboardingCompleted")

    var body: some View {
        if hasCompletedOnboarding {
            mainTabView
        } else {
            OnboardingView(isCompleted: $hasCompletedOnboarding)
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Início", systemImage: "moon.stars.fill")
            }
            .tag(AppTab.dashboard)

            NavigationStack {
                SleepListView()
            }
            .tabItem {
                Label("Sono", systemImage: "bed.double.fill")
            }
            .tag(AppTab.sleep)

            NavigationStack {
                CoachingView()
            }
            .tabItem {
                Label("Coaching", systemImage: "brain.head.profile")
            }
            .tag(AppTab.coaching)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.circle.fill")
            }
            .tag(AppTab.profile)
        }
        .tint(Color.appAccent)
    }
}

// MARK: - App Tab Enum

enum AppTab: String, CaseIterable {
    case dashboard
    case sleep
    case coaching
    case profile
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [
            SleepEntry.self,
            CircadianProfile.self,
            CoachingRecommendation.self,
            CircadianScore.self
        ], inMemory: true)
}
