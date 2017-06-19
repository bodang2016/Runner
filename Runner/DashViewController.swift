//
//  ViewController.swift
//  Runner
//
//  Created by Bodang on 19/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import MapKit
import Foundation

//This is the controller class of dash view, it provides the Outlet and Action functions for the UI components
class DashViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    var runningBrain = RunningBrain()
    fileprivate var timeIndicatorValue: String {
        get {
            return String(timeIndicator.text!)!
        }
        set {
            timeIndicator.text = String(newValue)
        }
    }
    fileprivate var distanceIndicatorValue: String {
        get {
            return String(distanceIndicator.text!)!
        }
        set {
            distanceIndicator.text = String(newValue)
        }
    }
    fileprivate var paceIndicatorValue: String {
        get {
            return String(paceIndicator.text!)!
        }
        set {
            paceIndicator.text = String(newValue)
        }
    }
    
    var colors:[UIColor] = [.white, .white, .white, .white]
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
    
    var timer: Int?
    var distance: Double?
    var pace: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Adjust UI
        
        //Init listener
        quickStart.addTarget(self, action: #selector(self.quickStartAction(sender:)), for: .touchUpInside)
        distanceRunStart.addTarget(self, action: #selector(self.distanceRunStartAction(sender:)), for: .touchUpInside)
        timedRunStart.addTarget(self, action: #selector(self.timedRunStartAction(sender:)), for: .touchUpInside)
        paceRunStart.addTarget(self, action: #selector(self.paceRunStartAction(sender:)), for: .touchUpInside)
        distanceMinus.addTarget(self, action: #selector(self.distanceMinusAction(sender:)), for: .touchUpInside)
        distancePlus.addTarget(self, action: #selector(self.distancePlusAction(sender:)), for: .touchUpInside)
        timeMinus.addTarget(self, action: #selector(self.timeMinusAction(sender:)), for: .touchUpInside)
        timePlus.addTarget(self, action: #selector(self.timePlusAction(sender:)), for: .touchUpInside)
        paceMinus.addTarget(self, action: #selector(self.paceMinusAction(sender:)), for: .touchUpInside)
        pacePlus.addTarget(self, action: #selector(self.pacePlusAction(sender:)), for: .touchUpInside)
        
        //Location Delegate
        runningBrain.getLocationManager().delegate = self
        runningBrain.getLocationManager().desiredAccuracy = kCLLocationAccuracyBestForNavigation
        runningBrain.getLocationManager().requestAlwaysAuthorization()
        
        MapView.mapType = .standard
        
        configurePageControl()
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        self.scrollView.isPagingEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for index in 0..<4 {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            let subView = UIView(frame: frame)
            switch index {
            case 0:
                quickStart.translatesAutoresizingMaskIntoConstraints = false
                quickStart.layer.cornerRadius = 6.5
                quickStart.setTitle("Quick Start", for: UIControlState.normal)
                quickStart.setTitleColor(.white, for: .normal)
                quickStart.setTitleColor(UIColor.lightText, for: .highlighted)
                quickStart.backgroundColor = itemColor
                subView.addSubview(quickStart)
                addConstrantToQuickStart(button: quickStart, view: subView)
            case 1:
                timedRunStart.translatesAutoresizingMaskIntoConstraints = false
                timedRunStart.layer.cornerRadius = 6.5
                timedRunStart.setTitle("Start Timed Run", for: UIControlState.normal)
                timedRunStart.setTitleColor(UIColor.lightText, for: .highlighted)
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
                distanceRunStart.setTitleColor(UIColor.lightText, for: .highlighted)
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
                paceRunStart.setTitleColor(UIColor.lightText, for: .highlighted)
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
                break
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
    
    //Action of UIButton
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if let RunningVC = destinationVC as? RunningViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "showRunningView":
                    RunningVC.runningType = "quickStart"
                    break
                case "showDistanceRunningView" :
                    RunningVC.runningType = "distanceStart"
                    RunningVC.distanceSet = distance!
                    break
                case "showTimedRunningView" :
                    RunningVC.runningType = "timedStart"
                    RunningVC.timerSet = timer!
                    break
                case "showPaceRunningView" :
                    RunningVC.runningType = "paceStart"
                    RunningVC.paceSet = pace!
                    break
                default:
                    return
                }
            }
        }
        
    }

    
    func quickStartAction(sender: UIButton) {
        self.performSegue(withIdentifier: "showRunningView", sender: UIButton.self)
    }
    
    func distanceRunStartAction(sender: UIButton) {
        distance = Double(distanceIndicatorValue)
        print("distance \(distanceIndicatorValue)")
        self.performSegue(withIdentifier: "showDistanceRunningView", sender: UIButton.self)
    }
    
    func timedRunStartAction(sender: UIButton) {
        var timeIndicatorValueArr = timeIndicatorValue.components(separatedBy: ":")
        let timeIndicatorMinute: Int = Int(timeIndicatorValueArr[0])!
        let timeIndicatorSecond: Int? = timeIndicatorValueArr.count > 1 ? Int(timeIndicatorValueArr[1]) : nil
        print("minute \(timeIndicatorMinute) second \(timeIndicatorSecond!)")
        timer = timeIndicatorMinute * 60 + timeIndicatorSecond!
        self.performSegue(withIdentifier: "showTimedRunningView", sender: UIButton.self)
    }
    
    func paceRunStartAction(sender: UIButton) {
        var paceIndicatorValueArr = paceIndicatorValue.components(separatedBy: ":")
        let paceIndicatorMinute: String = paceIndicatorValueArr[0]
        let paceIndicatorSecond: String? = paceIndicatorValueArr.count > 1 ? paceIndicatorValueArr[1] : nil
        print("minute \(paceIndicatorMinute) second \(paceIndicatorSecond!)")
        pace = Double(paceIndicatorMinute)! * 60 + Double(paceIndicatorSecond!)!
        self.performSegue(withIdentifier: "showPaceRunningView", sender: UIButton.self)
    }
    
    func distanceMinusAction(sender: UIButton) {
        var temp = Double(distanceIndicatorValue)
        if temp! > 0.1 {
            temp! -= 0.1
            distanceIndicatorValue = String(temp!)
        }
    }
    
    func distancePlusAction(sender: UIButton) {
        var temp = Double(distanceIndicatorValue)
        temp! += 0.1
        distanceIndicatorValue = String(temp!)
    }
    
    func timeMinusAction(sender: UIButton) {
        var timeIndicatorValueArr = timeIndicatorValue.components(separatedBy: ":")
        var timeIndicatorMinute: Int = Int(timeIndicatorValueArr[0])!
        var timeIndicatorSecond: Int? = timeIndicatorValueArr.count > 1 ? Int(timeIndicatorValueArr[1]) : nil
        if timeIndicatorMinute == 1 && timeIndicatorSecond == 0 {
            return
        } else if timeIndicatorSecond! == 0 {
            timeIndicatorSecond! = 50
            timeIndicatorMinute -= 1
        } else {
            timeIndicatorSecond! -= 10
        }
        timeIndicatorValue = "\(String(timeIndicatorMinute)):\(String(format: "%02d", timeIndicatorSecond!))"
    }
    
    func timePlusAction(sender: UIButton) {
        var timeIndicatorValueArr = timeIndicatorValue.components(separatedBy: ":")
        var timeIndicatorMinute: Int = Int(timeIndicatorValueArr[0])!
        var timeIndicatorSecond: Int? = timeIndicatorValueArr.count > 1 ? Int(timeIndicatorValueArr[1]) : nil
        if timeIndicatorSecond! < 50 {
            timeIndicatorSecond! += 10
        } else {
            timeIndicatorSecond! = 0
            timeIndicatorMinute += 1
        }
        timeIndicatorValue = "\(String(timeIndicatorMinute)):\(String(format: "%02d", timeIndicatorSecond!))"
    }
    
    func paceMinusAction(sender: UIButton) {
        var paceIndicatorValueArr = paceIndicatorValue.components(separatedBy: ":")
        var paceIndicatorMinute: Int = Int(paceIndicatorValueArr[0])!
        var paceIndicatorSecond: Int? = paceIndicatorValueArr.count > 1 ? Int(paceIndicatorValueArr[1]) : nil
        if paceIndicatorMinute == 1 && paceIndicatorSecond == 0 {
            return
        } else if paceIndicatorSecond! == 0 {
            paceIndicatorSecond! = 50
            paceIndicatorMinute -= 1
        } else {
            paceIndicatorSecond! -= 10
        }
        paceIndicatorValue = "\(String(paceIndicatorMinute)):\(String(format: "%02d", paceIndicatorSecond!))"
    }
    
    func pacePlusAction(sender: UIButton) {
        var paceIndicatorValueArr = paceIndicatorValue.components(separatedBy: ":")
        var paceIndicatorMinute: Int = Int(paceIndicatorValueArr[0])!
        var paceIndicatorSecond: Int? = paceIndicatorValueArr.count > 1 ? Int(paceIndicatorValueArr[1]) : nil
        if paceIndicatorSecond! < 50 {
            paceIndicatorSecond! += 10
        } else {
            paceIndicatorSecond! = 0
            paceIndicatorMinute += 1
        }
        paceIndicatorValue = "\(String(paceIndicatorMinute)):\(String(format: "%02d", paceIndicatorSecond!))"
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
    }
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        let errorType = error.localizedDescription
//        let alertController = UIAlertController(title: "GPS Signal Lost", message: errorType, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            runningBrain.getLocationManager().startUpdatingLocation()
            MapView.showsUserLocation = true
        default:
            runningBrain.getLocationManager().stopUpdatingLocation()
            MapView.showsUserLocation = false
        }
    }


}
