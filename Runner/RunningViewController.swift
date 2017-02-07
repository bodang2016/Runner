//
//  RunningViewController.swift
//  Runner
//
//  Created by Bodang on 24/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class RunningViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate{
    
    var runningBrain = RunningBrain()
    var runningType: String?
    var velocityUse = 0.0
    
    var timerCount = 0
    var timerStr: String?
    var timer = Timer()
    var weight = 70.0
    
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let mapView: MKMapView = MKMapView()
    let returnButton: UIButton = UIButton()
    
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var mainCaption: UILabel!
    @IBOutlet weak var mainIndicator: UILabel!
    @IBOutlet weak var secondIndicator: UILabel!
    @IBOutlet weak var secondCaption: UILabel!
    @IBOutlet weak var caloriesIndicator: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var BottomView: UIView!
    @IBAction func pauseButtonAction(_ sender: UIButton) {
        if sender.currentTitle == "Pause" {
            if CLLocationManager.locationServicesEnabled(){
                runningBrain.getLocationManager().stopUpdatingLocation()
                sender.setTitle("Resume", for: .normal)
                sender.backgroundColor = UIColor(red: 253/255, green: 181/255, blue: 69/255, alpha: 1)
                pauseRunning()
            }
        } else {
            runningBrain.getLocationManager().startUpdatingLocation()
            sender.backgroundColor = UIColor(red: 131/255, green: 211/255, blue: 132/255, alpha: 1)
            sender.setTitle("Pause", for: .normal)
            resumeRunning()
        }
    }
    @IBAction func stopButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Adjust UI
        BottomView.layer.shadowColor = UIColor.lightGray.cgColor
        BottomView.layer.shadowOpacity = 0.8
        topView.layer.shadowColor = UIColor.lightGray.cgColor
        topView.layer.shadowOpacity = 0.8
        topView.layer.shadowOffset = CGSize(width: 0, height: 4)
        stopButton.layer.cornerRadius = 20
        pauseButton.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        self.scrollView.isPagingEnabled = true
        
        startRunning()
        
        runningBrain.getLocationManager().delegate = self
        runningBrain.getLocationManager().desiredAccuracy = kCLLocationAccuracyBestForNavigation
        runningBrain.getLocationManager().requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for index in 0..<2 {
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            self.scrollView.isPagingEnabled = true
            let subView = UIView(frame: frame)
            switch index {
            case 0:
//                subView.addSubview(subView)
                break;
            case 1:
                subView.addSubview(mapView)
                subView.addSubview(returnButton)
                initMapView(mapView: mapView, view: subView)
                initReturnButton(button: returnButton, view: subView)
            default:
                break
            }
            self.scrollView .addSubview(subView)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 2, height: self.scrollView.frame.size.height)
            pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        }
    }

    func initMapView(mapView: MKMapView, view: UIView) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = .standard
        let constraintMapViewPosX: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraintMapViewPosY: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let constraintMapViewWidth: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let constraintMapViewHeight: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraints([constraintMapViewPosX, constraintMapViewPosY, constraintMapViewWidth, constraintMapViewHeight])
        mapView.showsUserLocation = true
    }
    
    func initReturnButton(button: UIButton, view: UIView) {
        button.setImage(UIImage(named:"returnIcon"), for: .normal)
        button.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        button.layer.cornerRadius = 6.5
        button.addTarget(self, action: #selector(self.returnButtonAction(sender:)), for: .touchUpInside)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        let constraintMapViewPosX: NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 10.0)
        let constraintMapViewPosY: NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -17.0)
        let constraintMapViewWidth: NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.1, constant: 0.0)
        let constraintMapViewHeight: NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.1, constant: 0.0)
        view.addConstraints([constraintMapViewPosX, constraintMapViewPosY, constraintMapViewWidth, constraintMapViewHeight])

    }
    
    func returnButtonAction(sender: UIButton) {
        scrollView.setContentOffset(CGPoint(x: 0,y :0), animated: true)
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func updateTime() {
        timerCount += 1
        let minutes = UInt8(timerCount / 60)
        let seconds = UInt8(timerCount % 60)
        
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", seconds)
        switch runningType! {
        case "quickStart":
            mainIndicator.text = "\(minutesString):\(secondsString)"
            break
        case "distanceStart":
            secondIndicator.text = "\(minutesString):\(secondsString)"
            break
        default:
            break
        }
    }
    func startRunning() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    func pauseRunning() {
        timer.invalidate()
    }
    func resumeRunning() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var caloriesStr = "-"
        let currentLocation = locations.last!
        if currentLocation.horizontalAccuracy < 0 || currentLocation.horizontalAccuracy>100 {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
        
        velocityUse = runningBrain.smoothingVelocityWithKalmanFiltering(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
        let paceSmoothInMinute = runningBrain.calculatePaceRate(Velocity: velocityUse)["minute"]!
        let paceSmoothInSecond = runningBrain.calculatePaceRate(Velocity: velocityUse)["second"]!
        let paceSmoothInMinuteNorm = String(format:"%02d",paceSmoothInMinute)
        let paceSmoothInSecondNorm = String(format:"%02d",paceSmoothInSecond)
        let paceStr = "\(paceSmoothInMinuteNorm):\(paceSmoothInSecondNorm)"
       
        let calories = runningBrain.calculateCalories(Velocity: velocityUse, Weight: weight, Time: Double(timerCount))
        if calories != 0 {
            caloriesStr = String(format:"%.2f",calories)
        }

        switch runningType! {
            case "quickStart":
                mainCaption.text = "Time"
                secondCaption.text = "Pace"
                secondIndicator.text = paceStr
                caloriesIndicator.text = caloriesStr
            default:
                break
            }
        
      
//                longitudeLbl.text = "Longitude: \(currentLocation.coordinate.longitude)"
//                latitudeLbl.text = "Latitude: \(currentLocation.coordinate.latitude)"
//                altitudeLbl.text = "Altitude: \(currentLocation.altitude)"
//                horizontalAccuracyLbl.text = "Horizontal accuracy: \(currentLocation.horizontalAccuracy)"
//                verticalAccuracyLbl.text = "Vertical accuracy: \(currentLocation.verticalAccuracy)"
//                headingLbl.text = "Heading: \(currentLocation.course)"
//                velocityLbl.text = "Velocity: \(velocityUse)"
//                paceSmoothLbl.text = "PaceSmooth: \(paceSmoothInMinuteNorm):\(paceSmoothInSecondNorm)"
//                paceLbl.text = "Pace: \(paceInMinuteNorm):\(paceInSecondNorm)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
            //need change!!!!!!!!!!!!!
            
        case .authorizedAlways, .authorizedWhenInUse:
            runningBrain.getLocationManager().startUpdatingLocation()
            mapView.showsUserLocation = true
        default:
            runningBrain.getLocationManager().stopUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
