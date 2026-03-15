// Services/HealthKitService.swift
// Serviço de integração com HealthKit para dados fisiológicos

import HealthKit
import Foundation
import OSLog

private let logger = Logger(subsystem: "br.com.circadiacare", category: "HealthKit")

actor HealthKitService {

    private let store = HKHealthStore()

    private let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []
        let identifiers: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .bodyTemperature,
            .stepCount,
            .activeEnergyBurned
        ]
        for id in identifiers {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        return types
    }()

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw AppError.healthKitNotAvailable
        }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            logger.info("HealthKit autorizado com sucesso")
        } catch {
            logger.error("Falha na autorização HealthKit: \(error.localizedDescription)")
            throw AppError.healthKitPermissionDenied
        }
    }

    // MARK: - Sleep Data

    func fetchSleepData(for date: Date) async throws -> SleepHealthData {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw AppError.healthDataUnavailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: AppError.healthDataFetchFailed(error.localizedDescription))
                    return
                }
                let sleepSamples = samples as? [HKCategorySample] ?? []
                let data = SleepHealthData.from(samples: sleepSamples)
                continuation.resume(returning: data)
            }
            self.store.execute(query)
        }
    }

    // MARK: - Heart Rate

    func fetchHeartRateStats(for date: Date) async throws -> HeartRateStats {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw AppError.healthDataUnavailable
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMin, .discreteMax]
            ) { _, stats, error in
                if let error {
                    continuation.resume(throwing: AppError.healthDataFetchFailed(error.localizedDescription))
                    return
                }
                let unit = HKUnit.count().unitDivided(by: .minute())
                let avg = stats?.averageQuantity()?.doubleValue(for: unit) ?? 0
                let min = stats?.minimumQuantity()?.doubleValue(for: unit) ?? 0
                let max = stats?.maximumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: HeartRateStats(average: avg, minimum: min, maximum: max))
            }
            self.store.execute(query)
        }
    }
}

// MARK: - Data Transfer Objects

struct SleepHealthData {
    var deepSleepMinutes: Int = 0
    var remSleepMinutes: Int = 0
    var lightSleepMinutes: Int = 0
    var awakeMinutes: Int = 0
    var bedtime: Date?
    var wakeTime: Date?

    static func from(samples: [HKCategorySample]) -> SleepHealthData {
        var data = SleepHealthData()
        guard !samples.isEmpty else { return data }

        data.bedtime = samples.first?.startDate
        data.wakeTime = samples.last?.endDate

        for sample in samples {
            let minutes = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
            switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
            case .asleepDeep:  data.deepSleepMinutes += minutes
            case .asleepREM:   data.remSleepMinutes += minutes
            case .asleepCore:  data.lightSleepMinutes += minutes
            case .awake:       data.awakeMinutes += minutes
            default:           break
            }
        }
        return data
    }
}

struct HeartRateStats {
    let average: Double
    let minimum: Double
    let maximum: Double
}
