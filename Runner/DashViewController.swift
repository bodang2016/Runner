//
//  ViewController.swift
//  Runner
//
//  Created by Bodang on 19/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import MapKit

class DashViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    var runningBrain = RunningBrain()
    
    var colors:[UIColor] = [.white, UIColor.white, UIColor.white, UIColor.white]
    var itemColor = UIColor(red: 212 / 255.0, green: 25 / 255.0, blue: 38 / 255.0, alpha: 1.0)
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    let quickStart: UIButton = UIButton()
    
    let timedRunStart: UIButton = UIButton()
    let timeMinus: UIButton = UIButton()
    let timePlus: UIButton = UIButton()
    let timeIndicator: UILabel = UILabel()
    
    let distanceRunStart: UIButton = UIButton()
    let distanceMinus: UIButton = UIButton()
    let distancePlus: UIButton = UIButton()
    let distanceIndicator: UILabel = UILabel()
    
    let paceRunStart: UIButton = UIButton()
    let paceMinus: UIButton = UIButton()
    let pacePlus: UIButton = UIButton()
    let paceIndicator: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Adjust UI
        
        //Init listener
        quickStart.addTarget(self, action: #selector(self.quickStartAction(sender:)), for: .touchUpInside)
        
        //Location Delegate
        runningBrain.getLocationManager().delegate = self
        runningBrain.getLocationManager().desiredAccuracy = kCLLocationAccuracyBestForNavigation
        runningBrain.getLocationManager().requestAlwaysAuthorization()
        
        MapView.mapType = .standard
        
        configurePageControl()
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for index in 0..<4 {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            self.scrollView.isPagingEnabled = true
            
            let subView = UIView(frame: frame)
            switch index {
            case 0:
                subView.backgroundColor = colors[index]
                quickStart.translatesAutoresizingMaskIntoConstraints = false
                quickStart.layer.cornerRadius = 6.5
                quickStart.setTitle("Quick Start", for: UIControlState.normal)
                quickStart.setTitleColor(.white, for: .normal)
                quickStart.backgroundColor = itemColor
                subView.addSubview(quickStart)
                addConstrantToQuickStart(button: quickStart, view: subView)
            case 1:
                subView.backgroundColor = colors[index]
                
                timedRunStart.translatesAutoresizingMaskIntoConstraints = false
                timedRunStart.layer.cornerRadius = 6.5
                timedRunStart.setTitle("Start Timed Run", for: UIControlState.normal)
                timedRunStart.backgroundColor = itemColor
                subView.addSubview(timedRunStart)
                
                timeMinus.translatesAutoresizingMaskIntoConstraints = false
                timeMinus.layer.cornerRadius = 15
                timeMinus.setTitle("-", for: UIControlState.normal)
                timeMinus.backgroundColor = itemColor
                timeMinus.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                timeMinus.alpha = 0.3
                subView.addSubview(timeMinus)
                
                timePlus.translatesAutoresizingMaskIntoConstraints = false
                timePlus.layer.cornerRadius = 15
                timePlus.setTitle("+", for: UIControlState.normal)
                timePlus.backgroundColor = itemColor
                timePlus.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                timePlus.alpha = 0.7
                subView.addSubview(timePlus)
                
                timeIndicator.translatesAutoresizingMaskIntoConstraints = false
                timeIndicator.text = "30:00"
                timeIndicator.textColor = itemColor
                timeIndicator.textAlignment = .center
                timeIndicator.font = UIFont.systemFont(ofSize: 45)
                subView.addSubview(timeIndicator)
                addConstrantToNormalStart(startButton: timedRunStart, minusButton: timeMinus, plusButton: timePlus, indicator: timeIndicator, view: subView)
            case 2:
                subView.backgroundColor = colors[index]
                
                distanceRunStart.translatesAutoresizingMaskIntoConstraints = false
                distanceRunStart.layer.cornerRadius = 6.5
                distanceRunStart.setTitle("Start Distance Run", for: UIControlState.normal)
                distanceRunStart.backgroundColor = itemColor
                subView.addSubview(distanceRunStart)
                
                distanceMinus.translatesAutoresizingMaskIntoConstraints = false
                distanceMinus.layer.cornerRadius = 15
                distanceMinus.setTitle("-", for: UIControlState.normal)
                distanceMinus.backgroundColor = itemColor
                distanceMinus.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                distanceMinus.alpha = 0.3
                subView.addSubview(distanceMinus)
                
                distancePlus.translatesAutoresizingMaskIntoConstraints = false
                distancePlus.layer.cornerRadius = 15
                distancePlus.setTitle("+", for: UIControlState.normal)
                distancePlus.backgroundColor = itemColor
                distancePlus.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                distancePlus.alpha = 0.7
                subView.addSubview(distancePlus)
                
                distanceIndicator.translatesAutoresizingMaskIntoConstraints = false
                distanceIndicator.text = "5.0"
                distanceIndicator.textColor = itemColor
                distanceIndicator.textAlignment = .center
                distanceIndicator.font = UIFont.systemFont(ofSize: 45)
                subView.addSubview(distanceIndicator)
                addConstrantToNormalStart(startButton:  distanceRunStart, minusButton:  distanceMinus, plusButton:  distancePlus, indicator: distanceIndicator, view: subView)
            case 3:
                subView.backgroundColor = colors[index]
                
                paceRunStart.translatesAutoresizingMaskIntoConstraints = false
                paceRunStart.layer.cornerRadius = 6.5
                paceRunStart.setTitle("Start Pace Run", for: UIControlState.normal)
                paceRunStart.backgroundColor = itemColor
                subView.addSubview(paceRunStart)
                
                paceMinus.translatesAutoresizingMaskIntoConstraints = false
                paceMinus.layer.cornerRadius = 15
                paceMinus.setTitle("-", for: UIControlState.normal)
                paceMinus.backgroundColor = itemColor
                paceMinus.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                paceMinus.alpha = 0.3
                subView.addSubview(paceMinus)
                
                pacePlus.translatesAutoresizingMaskIntoConstraints = false
                pacePlus.layer.cornerRadius = 15
                pacePlus.setTitle("+", for: UIControlState.normal)
                pacePlus.backgroundColor = itemColor
                pacePlus.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                pacePlus.alpha = 0.7
                subView.addSubview(pacePlus)
                
                paceIndicator.translatesAutoresizingMaskIntoConstraints = false
                paceIndicator.text = "8:00"
                paceIndicator.textColor = itemColor
                paceIndicator.textAlignment = .center
                paceIndicator.font = UIFont.systemFont(ofSize: 45)
                subView.addSubview(paceIndicator)
                addConstrantToNormalStart(startButton:  paceRunStart, minusButton:  paceMinus, plusButton:  pacePlus, indicator: paceIndicator, view: subView)
            default:
                break;
            }
            self.scrollView .addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 4, height: self.scrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)

    }
    
    func addConstrantToQuickStart(button: UIButton, view: UIView) {
        let constraintPosX:NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraintPosY:NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let constraintHeight:NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.2, constant: 0.0)
        let constraintWidth:NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0.0)
        view.addConstraints([constraintPosX, constraintPosY, constraintWidth, constraintHeight])
    }
    
    func addConstrantToNormalStart(startButton: UIButton, minusButton: UIButton, plusButton:UIButton, indicator:UILabel, view: UIView) {
        //Indicator
        let constraintIndicatorPosX:NSLayoutConstraint = NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraintIndicatorPosY:NSLayoutConstraint = NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: -30.0)
        let constraintIndicatorHeight:NSLayoutConstraint = NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.3, constant: 0.0)
        let constraintIndicatorWidth:NSLayoutConstraint = NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.4, constant: 0.0)
        //Minus Button
        let constraintMinusPosX:NSLayoutConstraint = NSLayoutConstraint(item: minusButton, attribute: .trailing, relatedBy: .equal, toItem: indicator, attribute: .leading, multiplier: 1, constant: -20)
        let constraintMinusPosY:NSLayoutConstraint = NSLayoutConstraint(item: minusButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: -30.0)
        let constraintMinusHeight:NSLayoutConstraint = NSLayoutConstraint(item: minusButton, attribute: .height, relatedBy: .equal, toItem: indicator, attribute: .height, multiplier: 0.8, constant: 0.0)
        let constraintMinusWidth:NSLayoutConstraint = NSLayoutConstraint(item: minusButton, attribute: .width, relatedBy: .equal, toItem: minusButton, attribute: .height, multiplier: 1.0, constant: 0.0)
        //Plus Button
        let constraintPlusPosX:NSLayoutConstraint = NSLayoutConstraint(item: plusButton, attribute: .leading, relatedBy: .equal, toItem: indicator, attribute: .trailing, multiplier: 1, constant: 20)
        let constraintPlusPosY:NSLayoutConstraint = NSLayoutConstraint(item: plusButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: -30.0)
        let constraintPlusHeight:NSLayoutConstraint = NSLayoutConstraint(item: plusButton, attribute: .height, relatedBy: .equal, toItem: indicator, attribute: .height, multiplier: 0.8, constant: 0.0)
        let constraintPlusWidth:NSLayoutConstraint = NSLayoutConstraint(item: plusButton, attribute: .width, relatedBy: .equal, toItem: minusButton, attribute: .height, multiplier: 1.0, constant: 0.0)
        //Start Button
        let constraintStartPosX:NSLayoutConstraint = NSLayoutConstraint(item: startButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let constraintStartPosY:NSLayoutConstraint = NSLayoutConstraint(item: startButton, attribute: .top, relatedBy: .equal, toItem: indicator, attribute: .bottom, multiplier: 1.0, constant: 20.0)
        let constraintStartHeight:NSLayoutConstraint = NSLayoutConstraint(item: startButton, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.2, constant: 0.0)
        let constraintStartWidth:NSLayoutConstraint = NSLayoutConstraint(item: startButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0.0)

        view.addConstraints([constraintIndicatorPosX, constraintIndicatorPosY, constraintIndicatorHeight, constraintIndicatorWidth, constraintMinusPosX, constraintMinusPosY, constraintMinusHeight, constraintMinusWidth, constraintPlusPosX, constraintPlusPosY, constraintPlusHeight, constraintPlusWidth, constraintStartPosX, constraintStartPosY, constraintStartHeight, constraintStartWidth])
    }
    
    func quickStartAction(sender: UIButton) {
        
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = colors.count
        self.pageControl.currentPage = 0
        self.pageControl.currentPageIndicatorTintColor = itemColor
        self.pageControl.pageIndicatorTintColor = .lightGray
        self.view.addSubview(pageControl)
        
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
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
