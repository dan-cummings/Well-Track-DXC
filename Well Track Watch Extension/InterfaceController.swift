//
//  InterfaceController.swift
//  Well Track Watch Extension
//
//  Created by Daniel Cummings on 4/7/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import HealthKit


class InterfaceController: WKInterfaceController {
    
    private var heartRateAnchoredQuery: HKAnchoredObjectQuery!
    private var myAnchor: HKQueryAnchor!
    private var healthstore: HKHealthStore!
    private var workoutSession: HKWorkoutSession!
    
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var heartRateButton: WKInterfaceButton!
    var readingHeartrate: Bool = false
    
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if HKHealthStore.isHealthDataAvailable() {
            self.healthstore = HKHealthStore()
            let readTypes: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
            self.healthstore.requestAuthorization(toShare: nil, read: readTypes) { (set, error) in
                if set {
                    print("authorized")
                }
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    @IBAction func startMonitor() {
        if readingHeartrate {
            self.healthstore.end(self.workoutSession)
            self.healthstore.stop(self.heartRateAnchoredQuery)
            heartRateButton.setTitle("Start")
        } else {
            
            // Create a new workout session
            let config = HKWorkoutConfiguration()
            config.activityType = .running
            config.locationType = .indoor
            do {
                self.workoutSession = try HKWorkoutSession(configuration: config)
                self.workoutSession.delegate = self
            } catch let error {
                fatalError("Workout not created: \(error.localizedDescription)")
            }
            healthstore.start(self.workoutSession)
            
            let heartrateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
            let predicate = HKQuery.predicateForSamples(withStart: self.workoutSession.startDate, end: self.workoutSession.endDate, options: .strictStartDate)
            myAnchor = HKQueryAnchor.init(fromValue: 0)
            heartRateAnchoredQuery = HKAnchoredObjectQuery(type: heartrateType!, predicate: predicate, anchor: myAnchor, limit: Int(HKObjectQueryNoLimit)) { (query, returnedSamples, deletedObjects, anchor, error) in
                guard let samples = returnedSamples as? [HKQuantitySample] else {
                    return
                }
                self.myAnchor = anchor!
                self.heartRateLabel.setText("\((samples.last?.quantity.doubleValue(for: HKUnit.init(from: "count/min")))!) BPM")
            }
            
            heartRateAnchoredQuery.updateHandler = { (query, updateSamples, deletedObjects, anchor, error) in
                guard let samples = updateSamples as? [HKQuantitySample] else {
                    return
                }
                self.myAnchor = anchor!
                let heartrate = samples.last?.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
                self.heartRateLabel.setText("\(heartrate!) BPM")
                if self.session.isReachable {
                    let message = ["heartrate": heartrate as Any]
                    self.session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                }
            }
            self.healthstore.execute(heartRateAnchoredQuery)
            heartRateButton.setTitle("Stop")
        }
        readingHeartrate = !readingHeartrate
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension InterfaceController: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("\(toState.rawValue) from \(fromState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
