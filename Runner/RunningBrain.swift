//
//  RunnningBrain.swift
//  Runner
//
//  Created by Bodang on 20/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

class RunningBrain {
    private let locationManager: CLLocationManager = CLLocationManager()
    
    
    private var kalmanSwitch = 0
    private var velocityAssetsIndex = 0
    private var perviousVelocityAssetsIndex = 0
    private var velocityAssets: Array<Double> = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    private var previousVelocityAssets: Array<Double> = [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0]
    private var holdVelocity = 0.0
    private var holdAccuracy = 0.0
    private var startLocation: CLLocation!
    private var lastLocation: CLLocation!
    private var traveledDistance: Double = 0
    private var smoothStatus = 0
    
    func calculateDistance(start: CLLocation, end: CLLocation) -> Double {
        if startLocation == nil {
            startLocation = start 
        } else {
            let lastLocation = end
            let distance = startLocation.distance(from: lastLocation)
            startLocation = lastLocation
            traveledDistance += distance
        }
        return traveledDistance/1000
    }
    
    func calculateCalories(Distance: Double, Weight: Double, Time: Double) -> Double {
        return Distance/1.61 * Weight * 2.2 * 0.75
    }
    
    func smoothingVelocityWithAverageNumber(Velocity:Double, Accuracy: Double) -> Double {
        velocityAssets[velocityAssetsIndex % 10] = Velocity
        velocityAssetsIndex += 1
        smoothStatus = 1
        return (velocityAssets[0] + velocityAssets[1] + velocityAssets[2] + velocityAssets[3] + velocityAssets[4] + velocityAssets[5] + velocityAssets[6] + velocityAssets[7] + velocityAssets[8] + velocityAssets[9]) / 10
    }
    
    func smoothingVelocityWithThreeGapNumber(Velocity:Double, Accuracy: Double) -> Double {
        velocityAssets[velocityAssetsIndex % 10] = Velocity
        velocityAssetsIndex += 1
        return (velocityAssets[0] + velocityAssets[4] + velocityAssets[9]) / 3
    }
    
    func smoothingVelocityWithStanderDeviation(Velocity:Double, Accuracy: Double) -> Double {
        velocityAssets[velocityAssetsIndex % 10] = Velocity
        velocityAssetsIndex += 1
        var temp = 0.0
        let mean = (velocityAssets[0] + velocityAssets[1] + velocityAssets[2] + velocityAssets[3] + velocityAssets[4] + velocityAssets[5] + velocityAssets[6] + velocityAssets[7] + velocityAssets[8] + velocityAssets[9]) / 10
        for value in velocityAssets {
            temp += pow((value - mean), 2)
        }
        temp = sqrt(temp)
        temp = temp / 3 / sqrt(10)
        let result = velocityAssets.reduce( ([],[]), {
            (a:([Double],[Double]),n:Double) -> ([Double],[Double]) in
            (n>(mean-temp)&&n<(mean+temp)) ? (a.0+[n],a.1) : (a.0,a.1+[n])
        })
        if result.0.count == 0{
            return holdVelocity
        } else {
            temp = 0
            var i = 0
            for value in result.0 {
                i += 1
                temp += value
            }
            holdVelocity = temp / Double(i)
            return holdVelocity
        }
    }
    
    func smoothingVelocityWithKalmanFiltering(Velocity:Double, Accuracy: Double) -> Double {
        velocityAssets[velocityAssetsIndex % 10] = Velocity
        velocityAssetsIndex += 1
        let mean = (velocityAssets[0] + velocityAssets[1] + velocityAssets[2] + velocityAssets[3] + velocityAssets[4] + velocityAssets[5] + velocityAssets[6] + velocityAssets[7] + velocityAssets[8] + velocityAssets[9]) / 10
        let previousMeanVelocity = getPreviousVelocity()
        let previousDeviation = getPreviousDeviation()
        if(previousMeanVelocity < mean && Accuracy > 0) {
            holdVelocity = previousMeanVelocity + sqrt(pow(previousDeviation,2)/(pow(previousDeviation,2) + pow(mean - holdVelocity,-2))) * (mean - holdVelocity)
        } else if(previousMeanVelocity >= mean && Accuracy > 0){
            holdVelocity = previousMeanVelocity - sqrt(pow(previousDeviation,2)/(pow(previousDeviation,2) + pow(mean - holdVelocity,-2))) * (holdVelocity - mean)
        }
        if kalmanSwitch < 20 {
            kalmanSwitch += 1
            setPerviousVelocity(velocity: mean)
            smoothStatus = 1
        } else if velocityChanging() {
            if speeding() {
                for _ in 1...10 {
                    setPerviousVelocity(velocity: mean)
                }
            } else {
                setPerviousVelocity(velocity: mean)
            }
            smoothStatus = 1
        } else {
            setPerviousVelocity(velocity: holdVelocity)
            smoothStatus = 2
            print("kalman")
        }
        holdAccuracy = Accuracy
        return holdVelocity
    }
    
    func getSmoothStatus() -> Int {
        return smoothStatus
    }
    
    func calculatePaceRate(Velocity: Double) -> Dictionary<String, Int>{
        let pace: Double
        if Velocity < 0.1 {
            pace = 0
        } else {
            pace = 1000 / Velocity
        }
        let paceInMinute: Int = Int(pace) / 60
        let paceInSecond: Int = Int(pace) % 60
        let paceRate: Dictionary<String, Int> = [
            "minute": paceInMinute,
            "second": paceInSecond
        ]
        return paceRate
    }
    
    public func getLocationManager() -> CLLocationManager {
        return locationManager
    }
    
    public func setPerviousVelocity(velocity: Double) {
        previousVelocityAssets[perviousVelocityAssetsIndex % 10] = velocity
        perviousVelocityAssetsIndex += 1
    }
    
    public func getPreviousVelocity() -> Double {
        return (previousVelocityAssets[0] + previousVelocityAssets[1] + previousVelocityAssets[2] + previousVelocityAssets[3] + previousVelocityAssets[4] + previousVelocityAssets[5] + previousVelocityAssets[6] + previousVelocityAssets[7] + previousVelocityAssets[8] + previousVelocityAssets[9]) / 10
    }
    
    public func getPreviousDeviation() -> Double {
        var temp = 0.0
        for value in velocityAssets {
            temp += pow((value - getPreviousVelocity()), 2)
        }
        temp = sqrt(temp)
        temp = temp / 3 / sqrt(10)
        return temp
    }
    
    public func velocityChanging() -> Bool {
        return abs((velocityAssets[0] + velocityAssets[1] + velocityAssets[2] / 3) - (velocityAssets[7] + velocityAssets[8] + velocityAssets[9] / 3)) > 0.4
    }
    
    public func speeding() -> Bool {
        return abs((velocityAssets[0] + velocityAssets[1] + velocityAssets[2] / 3) - (velocityAssets[7] + velocityAssets[8] + velocityAssets[9] / 3)) > 1.5
    }
    
}
