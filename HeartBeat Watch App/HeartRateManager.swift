
import SwiftUI
import HealthKit

class HeartRateManager: ObservableObject {
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKObserverQuery?
    
    @Published var heartRate: Double = 0.0
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                self.startHeartRateQuery()
            } else {
                // Handle errors here
            }
        }
    }
    
    private func startHeartRateQuery() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, newAnchor, error in
            self.handleHeartRateSamples(samples)
        }
        
        query.updateHandler = { query, samples, deletedObjects, newAnchor, error in
            self.handleHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    private func handleHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            if let lastSample = samples.last {
                self.heartRate = lastSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
    }
}
