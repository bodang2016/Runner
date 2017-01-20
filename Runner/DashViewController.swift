//
//  ViewController.swift
//  Runner
//
//  Created by Bodang on 19/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import MapKit

class DashViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var MapView: MKMapView!
    var runningBrain = RunningBrain()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Location Delegate
        runningBrain.getLocationManager().delegate = self
        runningBrain.getLocationManager().desiredAccuracy = kCLLocationAccuracyBestForNavigation
        runningBrain.getLocationManager().requestAlwaysAuthorization()
        
        MapView.mapType = .standard
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        if currentLocation.horizontalAccuracy < 0 || currentLocation.horizontalAccuracy>100 {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000)
        MapView.setRegion(region, animated: true)
        
//        let paceInMinute = runningBrain.calculatePaceRate(Velocity: currentLocation.speed)["minute"]!
//        let paceInSecond = runningBrain.calculatePaceRate(Velocity: currentLocation.speed)["second"]!
//        switch algorithmUse {
//        case 0:
//            velocityUse = runningBrain.smoothingVelocityWithAverageNumber(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
//        case 1:
//            velocityUse = runningBrain.smoothingVelocityWithThreeGapNumber(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
//        case 2:
//            velocityUse = runningBrain.smoothingVelocityWithStanderDeviation(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
//        case 3:
//            velocityUse = runningBrain.smoothingVelocityWithKalmanFiltering(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
//        default:
//            break
//        }
//        let paceSmoothInMinute = runningBrain.calculatePaceRate(Velocity: velocityUse)["minute"]!
//        let paceSmoothInSecond = runningBrain.calculatePaceRate(Velocity: velocityUse)["second"]!
//        let paceInMinuteNorm = String(format:"%02d",paceInMinute)
//        let paceInSecondNorm = String(format:"%02d",paceInSecond)
//        let paceSmoothInMinuteNorm = String(format:"%02d",paceSmoothInMinute)
//        let paceSmoothInSecondNorm = String(format:"%02d",paceSmoothInSecond)
//        
//        longitudeLbl.text = "Longitude: \(currentLocation.coordinate.longitude)"
//        latitudeLbl.text = "Latitude: \(currentLocation.coordinate.latitude)"
//        altitudeLbl.text = "Altitude: \(currentLocation.altitude)"
//        horizontalAccuracyLbl.text = "Horizontal accuracy: \(currentLocation.horizontalAccuracy)"
//        verticalAccuracyLbl.text = "Vertical accuracy: \(currentLocation.verticalAccuracy)"
//        headingLbl.text = "Heading: \(currentLocation.course)"
//        velocityLbl.text = "Velocity: \(velocityUse)"
//        paceSmoothLbl.text = "PaceSmooth: \(paceSmoothInMinuteNorm):\(paceSmoothInSecondNorm)"
//        paceLbl.text = "Pace: \(paceInMinuteNorm):\(paceInSecondNorm)"
//        saveTestDataToDatabase(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorType = error.localizedDescription
        let alertController = UIAlertController(title: "Location Service Error", message: errorType, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        //need change!!!!!!!!!!!!!
            
        case .authorizedAlways, .authorizedWhenInUse:
            runningBrain.getLocationManager().startUpdatingLocation()
            MapView.showsUserLocation = true
        default:
            runningBrain.getLocationManager().stopUpdatingLocation()
            MapView.showsUserLocation = false
        }
    }


}

