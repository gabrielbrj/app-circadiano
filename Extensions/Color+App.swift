// Extensions/Color+App.swift
// Sistema de cores do CircadiaCare com suporte a Dark Mode

import SwiftUI

extension Color {

    // MARK: - Backgrounds
    static let appBackground = Color("appBackground")
    static let appCardBackground = Color("appCardBackground")

    // MARK: - Text
    static let appPrimary = Color("appPrimary")
    static let appSecondaryText = Color("appSecondaryText")

    // MARK: - Brand
    static let appAccent = Color("appAccent")

    // MARK: - Semantic
    static let appSuccess = Color("appSuccess")
    static let appWarning = Color("appWarning")
    static let appError = Color("appError")

    // MARK: - UI
    static let appSeparator = Color("appSeparator")

    // MARK: - Category Colors
    static let colorLight = Color("colorLight")
    static let colorCaffeine = Color("colorCaffeine")
    static let colorExercise = Color("colorExercise")
    static let colorSleep = Color("colorSleep")
    static let colorCognitive = Color("colorCognitive")
    static let colorNutrition = Color("colorNutrition")
}

// MARK: - Design System Documentation
/*
 Design System CircadiaCare — Paleta Noturna

 Light Mode:
 - appBackground:      #F2F0EC (off-white quente, evita branco puro que perturba sono)
 - appCardBackground:  #FFFFFF
 - appPrimary:         #1A1A2E (azul escuro quase preto)
 - appSecondaryText:   #6B7280
 - appAccent:          #6366F1 (índigo — associado a noite e céu estrelado)
 - appSuccess:         #10B981 (verde esmeralda)
 - appWarning:         #F59E0B (âmbar)
 - appError:           #EF4444 (vermelho)
 - appSeparator:       #E5E7EB

 Dark Mode:
 - appBackground:      #0D0D1A (azul muito escuro, mais suave que preto puro)
 - appCardBackground:  #1A1A2E
 - appPrimary:         #F0F0FF (branco levemente azulado)
 - appSecondaryText:   #9CA3AF
 - appAccent:          #818CF8 (índigo mais claro para contraste no dark)
 - appSuccess:         #34D399
 - appWarning:         #FBBF24
 - appError:           #F87171
 - appSeparator:       #2D2D44

 Category Colors:
 - colorLight:       Sol/luz     → #F59E0B (âmbar)
 - colorCaffeine:    Café        → #92400E (marrom)
 - colorExercise:    Exercício   → #10B981 (verde)
 - colorSleep:       Sono        → #6366F1 (índigo)
 - colorCognitive:   Cognição    → #8B5CF6 (violeta)
 - colorNutrition:   Nutrição    → #EF4444 (vermelho)
 */
