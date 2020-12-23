//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit
import HealthKit

class HealthDataStep: ORKInstructionStep {
    // MARK: Properties
    
    let healthDataItemsToRead: Set<HKObjectType> = [
        HKObjectType.electrocardiogramType(),
        HKSeriesType.heartbeat(),
        HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
        HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.vo2Max)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.forcedVitalCapacity)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.walkingHeartRateAverage)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!
    ]
    
    let healthDataItemsToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
        HKSeriesType.heartbeat(),
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
        HKObjectType.workoutType()
    ]
    
    // MARK: Initialization
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        title = NSLocalizedString("HEALTH_DATA", comment: "")
        text = NSLocalizedString("HEALTHKIT_PROMPT", comment: "")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Convenience
    
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = NSError(domain: "ecg.vagus.app", code: 2, userInfo: [NSLocalizedDescriptionKey: "HEALTHKIT_NOT_AVAILABLE"])
            completion(false, error)
            return
        }
        
        // Get authorization to access the data
        HKHealthStore().requestAuthorization(toShare: healthDataItemsToWrite, read: healthDataItemsToRead) { (success, error) -> Void in
            completion(success, error as NSError?)
        }
    }
}
