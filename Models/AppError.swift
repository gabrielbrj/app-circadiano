// Models/AppError.swift
// Enum centralizado de erros do aplicativo

import Foundation

enum AppError: LocalizedError, Equatable {

    // Persistência
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)

    // HealthKit
    case healthKitNotAvailable
    case healthKitPermissionDenied
    case healthDataUnavailable
    case healthDataFetchFailed(String)

    // Notificações
    case notificationPermissionDenied
    case notificationScheduleFailed(String)

    // Perfil
    case profileNotFound
    case profileSaveFailed(String)

    // Score
    case scoringFailed(String)
    case insufficientData

    // Genérico
    case unknown
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let msg):
            return "Falha ao salvar dados: \(msg)"
        case .fetchFailed(let msg):
            return "Falha ao carregar dados: \(msg)"
        case .deleteFailed(let msg):
            return "Falha ao excluir dados: \(msg)"
        case .healthKitNotAvailable:
            return "HealthKit não está disponível neste dispositivo"
        case .healthKitPermissionDenied:
            return "Permissão de acesso ao HealthKit negada. Acesse Ajustes > Saúde para autorizar."
        case .healthDataUnavailable:
            return "Dados de saúde não disponíveis para o período solicitado"
        case .healthDataFetchFailed(let msg):
            return "Falha ao buscar dados de saúde: \(msg)"
        case .notificationPermissionDenied:
            return "Permissão de notificação negada. Acesse Ajustes para habilitar."
        case .notificationScheduleFailed(let msg):
            return "Falha ao agendar notificação: \(msg)"
        case .profileNotFound:
            return "Perfil de usuário não encontrado"
        case .profileSaveFailed(let msg):
            return "Falha ao salvar perfil: \(msg)"
        case .scoringFailed(let msg):
            return "Falha ao calcular score circadiano: \(msg)"
        case .insufficientData:
            return "Dados insuficientes. Registre pelo menos 3 noites de sono para análise."
        case .unknown:
            return "Ocorreu um erro inesperado. Tente novamente."
        case .networkError(let msg):
            return "Erro de conexão: \(msg)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .healthKitPermissionDenied:
            return "Toque para abrir Ajustes"
        case .notificationPermissionDenied:
            return "Toque para abrir Ajustes"
        case .insufficientData:
            return "Registre suas noites de sono no app"
        default:
            return "Tente novamente"
        }
    }

    var failureReason: String? {
        switch self {
        case .healthKitNotAvailable:
            return "Dispositivo não suporta monitoramento de saúde"
        case .insufficientData:
            return "Poucos dados para análise circadiana"
        default:
            return nil
        }
    }

    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        return .unknown
    }
}
