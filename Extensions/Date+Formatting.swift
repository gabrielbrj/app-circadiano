// Extensions/Date+Formatting.swift
// Extensões de formatação de datas para o app

import Foundation

extension Date {

    // MARK: - Sleep-specific Formatting

    /// Formata horário de sono no padrão "23:30"
    var sleepTimeFormatted: String {
        formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }

    /// Formata a data como "Seg, 15 Jan"
    var shortDateFormatted: String {
        formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    /// Retorna o dia da semana abreviado ("Seg")
    var weekdayAbbreviated: String {
        formatted(.dateTime.weekday(.abbreviated))
    }

    /// Retorna apenas hora e minuto como "07:30"
    var hourMinuteFormatted: String {
        let hour = Calendar.current.component(.hour, from: self)
        let minute = Calendar.current.component(.minute, from: self)
        return String(format: "%02d:%02d", hour, minute)
    }

    /// Retorna string relativa: "Hoje", "Ontem", ou data formatada
    var relativeOrDateFormatted: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "Hoje" }
        if calendar.isDateInYesterday(self) { return "Ontem" }
        return formatted(.dateTime.weekday(.wide).day().month(.abbreviated))
    }

    // MARK: - Duration Calculation

    /// Duração entre duas datas formatada como "7h 30m"
    func durationFormatted(to endDate: Date) -> String {
        let seconds = Int(endDate.timeIntervalSince(self))
        guard seconds > 0 else { return "--" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours == 0 { return "\(minutes)m" }
        if minutes == 0 { return "\(hours)h" }
        return "\(hours)h \(minutes)m"
    }

    // MARK: - Circadian Helpers

    /// Retorna se a hora atual está dentro de uma janela circadiana
    func isWithinCircadianWindow(startHour: Int, endHour: Int) -> Bool {
        let hour = Calendar.current.component(.hour, from: self)
        if startHour <= endHour {
            return hour >= startHour && hour < endHour
        }
        // Janela cruza meia-noite
        return hour >= startHour || hour < endHour
    }

    /// Cria uma Data para hoje com hora e minuto específicos
    static func todayAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Retorna o início da semana atual
    var startOfWeek: Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: self)?.start ?? self
    }

    /// Retorna se a data é desta semana
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {

    /// Converte segundos em "Xh Ym"
    var hoursMinutesFormatted: String {
        let totalMinutes = Int(self / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours == 0 { return "\(minutes)m" }
        if minutes == 0 { return "\(hours)h" }
        return "\(hours)h \(minutes)m"
    }

    /// Converte segundos em horas decimais
    var hoursDecimal: Double {
        self / 3600
    }
}
