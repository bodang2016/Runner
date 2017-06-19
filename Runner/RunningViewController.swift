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
import Charts

//This is the controller class of running view, it provides the Outlet and Action functions for the UI components
class RunningViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var runningBrain = RunningBrain()
    var runningType: String?
    var velocityUse = 0.0
    
    var timerSet: Int?
    var distanceSet: Double?
    var paceSet: Double?
    
    var timerCount = 0
    var timerStr: String?
    var timer = Timer()
    var route = [CLLocationCoordinate2D]()
    
    var velocityAssetsIndex = 0
    var velocityAssets: Array<Double> = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var labelX = [" ", " ", " ", " ", " ", " ", " ", " ", " ", " "]
    let startTimeStemp = NSDate()
    var caloriesStr = "0"
    var distanceStr = "0"
    
    let defaults = UserDefaults.standard
    var age = 20
    var weight = 65.0
    var smoothLevel: Float = 2
    var gender = "Male"
    let secondPerYear = 31536000.0
    
    let genderConstant = "KEY_GENDER"
    let ageConstant = "KEY_AGE"
    let weightConstant = "KEY_WEIGHT"
    let smoothConstant = "KEY_SMOOTH"
    
    
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let mapView: MKMapView = MKMapView()
    let returnButton: UIButton = UIButton()
    
    let chartView = LineChartView()
    
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var mainCaption: UILabel!
    @IBOutlet weak var mainIndicator: UILabel!
    @IBOutlet weak var secondIndicator: UILabel!
    @IBOutlet weak var secondCaption: UILabel!
    @IBOutlet weak var thirdIndicator: UILabel!
    @IBOutlet weak var thirdCaption: UILabel!
    
    @IBOutlet weak var smoothIndicator: UIButton!
    @IBOutlet weak var smoothLabel: UILabel!
    
    @IBOutlet weak var signalLabel: UILabel!
    
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
        let alertController:UIAlertController=UIAlertController(title: "Finish Activity?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: "Finish", style: UIAlertActionStyle.destructive){
            (alertAction)->Void in
            self.runningBrain.getLocationManager().stopUpdatingLocation()
            CoreDataManager.saveRun(timeStamp: self.startTimeStemp, duration: Int16(self.timerCount), distance: Double(self.distanceStr)!, calories: Double(self.caloriesStr)!)
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.cancel,handler:nil))
        self.present(alertController, animated: true, completion: nil)
        
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
        
        loadPreference()
        
        startRunning()
        
        runningBrain.getLocationManager().delegate = self
        runningBrain.getLocationManager().desiredAccuracy = kCLLocationAccuracyBestForNavigation
        runningBrain.getLocationManager().requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for index in 0..<2 {
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            let subView = UIView(frame: frame)
            switch index {
            case 0:
                subView.addSubview(chartView)
                initChartView(chartView: chartView, view: subView)
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
        switch runningType! {
        case "quickStart":
            mainCaption.text = "Time"
            secondCaption.text = "Pace"
            thirdCaption.text = "Distance"
            break
        case "distanceStart":
            mainCaption.text = "Distance"
            secondCaption.text = "Pace"
            thirdCaption.text = "Time"
            break
            
        case "timedStart":
            mainCaption.text = "Time"
            secondCaption.text = "Pace"
            thirdCaption.text = "Distance"
            break
            
        case "paceStart":
            mainCaption.text = "Pace"
            secondCaption.text = "Distance"
            thirdCaption.text = "Time"
            break

        default:
            break
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: nil)
        lineChartDataSet.cubicIntensity = 0.2
        let lineChartData = LineChartData()
        lineChartDataSet.lineWidth = 1.8
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.circleRadius = 4
        lineChartDataSet.setCircleColor(.white)
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.fillColor = UIColor(red: 131/255, green: 211/255, blue: 132/255, alpha: 1)
        lineChartDataSet.fillAlpha = 0.5
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.circleRadius = 10
        lineChartData.addDataSet(lineChartDataSet)
        chartView.data = lineChartData
        chartView.drawGridBackgroundEnabled = false
        chartView.setScaleEnabled(false)
        chartView.leftAxis.axisMinimum = 0
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.drawLabelsEnabled = false
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
        mapView.delegate = self
    }
    
    func initChartView(chartView: LineChartView, view: UIView) {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        let constraintChartViewPosX: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraintChartViewPosY: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let constraintChartViewWidth: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let constraintChartViewHeight: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraints([constraintChartViewPosX, constraintChartViewPosY, constraintChartViewWidth, constraintChartViewHeight])
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
            if timerCount % 5 == 0 {
                velocityAssets[velocityAssetsIndex % 10] = velocityUse
                velocityAssetsIndex += 1
                var tempArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                for i in 0..<10 {
                    tempArray[i] = velocityAssets[(velocityAssetsIndex + i) % 10]
                }
                setChart(dataPoints: labelX, values: tempArray)
            }
            break
        case "distanceStart":
            thirdIndicator.text = "\(minutesString):\(secondsString)"
            if timerCount % 5 == 0 {
                velocityAssets[velocityAssetsIndex % 10] = velocityUse
                velocityAssetsIndex += 1
                var tempArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                for i in 0..<10 {
                    tempArray[i] = velocityAssets[(velocityAssetsIndex + i) % 10]
                }
                setChart(dataPoints: labelX, values: tempArray)
            }
            break
        case "timedStart":
            mainIndicator.text = "\(minutesString):\(secondsString)"
            if timerCount % 5 == 0 {
                velocityAssets[velocityAssetsIndex % 10] = velocityUse
                velocityAssetsIndex += 1
                var tempArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                for i in 0..<10 {
                    tempArray[i] = velocityAssets[(velocityAssetsIndex + i) % 10]
                }
                setChart(dataPoints: labelX, values: tempArray)
            }
            break
        case "paceStart":
            thirdIndicator.text = "\(minutesString):\(secondsString)"
            if timerCount % 5 == 0 {
                velocityAssets[velocityAssetsIndex % 10] = velocityUse
                velocityAssetsIndex += 1
                var tempArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                for i in 0..<10 {
                    tempArray[i] = velocityAssets[(velocityAssetsIndex + i) % 10]
                }
                setChart(dataPoints: labelX, values: tempArray)
            }
            if timerCount % 30 == 0 {
                if let checkPace = paceSet {
                    let velocity = 1000 / checkPace
                    if velocity - velocityUse > 0.3 {
                        let alertController:UIAlertController=UIAlertController(title: "Speed up", message: "Your are slower than your target", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(alertController, animated: true, completion: nil)
                        let time = DispatchTime.now() + 5
                        DispatchQueue.main.asyncAfter(deadline: time){
                            alertController.dismiss(animated: true, completion: nil)
                        }
                    } else if velocity - velocityUse < -0.3 {
                        let alertController:UIAlertController=UIAlertController(title: "Slow down", message: "Your are faster than your target", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(alertController, animated: true, completion: nil)
                        let time = DispatchTime.now() + 5
                        DispatchQueue.main.asyncAfter(deadline: time){
                            alertController.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
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
        let currentLocation = locations.last!
        if currentLocation.horizontalAccuracy < 0 || currentLocation.horizontalAccuracy > 100 {
            return
        }
        setSignalStatus(status: currentLocation.horizontalAccuracy)
        let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
        switch smoothLevel {
        case 0:
            velocityUse = currentLocation.speed
            setSmoothStatus(status: 0)
            break
        case 1:
            velocityUse = runningBrain.smoothingVelocityWithAverageNumber(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
            setSmoothStatus(status: 1)
            break
        case 2:
            velocityUse = runningBrain.smoothingVelocityWithKalmanFiltering(Velocity: currentLocation.speed, Accuracy: currentLocation.horizontalAccuracy)
            setSmoothStatus(status: runningBrain.getSmoothStatus())
            break
        default:
            velocityUse = 0
            break
        }
        if velocityUse < 0 {
            velocityUse = 0
        }
        let paceSmoothInMinute = runningBrain.calculatePaceRate(Velocity: velocityUse)["minute"]!
        let paceSmoothInSecond = runningBrain.calculatePaceRate(Velocity: velocityUse)["second"]!
        let paceSmoothInMinuteNorm = String(format:"%02d",paceSmoothInMinute)
        let paceSmoothInSecondNorm = String(format:"%02d",paceSmoothInSecond)
        let paceStr = "\(paceSmoothInMinuteNorm):\(paceSmoothInSecondNorm)"
        let distance = runningBrain.calculateDistance(start: locations.first!, end: locations.last!)
        if distance > 0 {
            distanceStr = String(format:"%.2f",distance)
        }
        let calories = runningBrain.calculateCalories(Distance: distance, Weight: weight, Time: Double(timerCount))
        if calories != 0 {
            caloriesStr = String(format:"%.2f",calories)
        }
        switch runningType! {
        case "quickStart":
            secondIndicator.text = paceStr
//          thirdIndicator.text = caloriesStr
            thirdIndicator.text = distanceStr
            break
        case "distanceStart":
            secondIndicator.text = paceStr
//          thirdIndicator.text = caloriesStr
            mainIndicator.text = distanceStr
            if let checkDistance = distanceSet {
                if checkDistance == Double(distanceStr) {
                    let alertController = UIAlertController(title: "congratulations!", message:
                        "You reach your goal", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            break
        case "timedStart":
            secondIndicator.text = paceStr
//          thirdIndicator.text = caloriesStr
            thirdIndicator.text = distanceStr
            if let checkTime = timerSet {
                if (checkTime == timerCount) {
                    let alertController = UIAlertController(title: "congratulations!", message:
                        "You reach your goal", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            break
        case "paceStart":
            mainIndicator.text = paceStr
//          thirdIndicator.text = caloriesStr
            secondIndicator.text = distanceStr
            break
        default:
            break
        }
        route.append(currentLocation.coordinate)
        createPolyline(mapView: mapView, route: route)
        CoreDataManager.saveLocation(velocity: velocityUse, longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude, timeStamp: currentLocation.timestamp as NSDate, startTimeStamp: startTimeStemp)
        
      
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
    
    func createPolyline(mapView: MKMapView, route: [CLLocationCoordinate2D]) {
        let geodesic = MKGeodesicPolyline(coordinates: route, count: route.count)
        self.mapView.add(geodesic)
        
//        UIView.animate(withDuration: 1.5, animations: { () -> Void in
//            let span = MKCoordinateSpanMake(0.01, 0.01)
//            let region1 = MKCoordinateRegion(center: route.first!, span: span)
//            self.mapView.setRegion(region1, animated: true)
//        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.init(red: 24/255, green: 128/255, blue: 251/255, alpha: 1.0)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    func loadPreference() {
        if let genderValue = defaults.string(forKey: genderConstant) {
            self.gender = genderValue
        }
        if let ageValue = defaults.data(forKey: ageConstant) {
            let date = NSKeyedUnarchiver.unarchiveObject(with: ageValue) as? Date
            let year: Double = Double(Date().timeIntervalSince(date!).description)! / self.secondPerYear
            self.age = Int(year)
        }
        if let weightValue = defaults.string(forKey: weightConstant) {
            self.weight = Double(weightValue)!
        }
        if let smoothValue = defaults.string(forKey: smoothConstant) {
            smoothLevel = Float(smoothValue)!
        }
    }
    
    func setSmoothStatus(status: Int) {
        switch status {
        case 0:
            smoothIndicator.setImage(UIImage(named:"smooth_raw"), for: .normal)
            smoothLabel.text = "Raw"
            break
        case 1:
            smoothIndicator.setImage(UIImage(named:"smooth_average"), for: .normal)
            smoothLabel.text = "Average"
            break
        case 2:
            smoothIndicator.setImage(UIImage(named:"smooth_kalman"), for: .normal)
            smoothLabel.text = "Kalman"
            break
        default:
            smoothIndicator.setImage(UIImage(named:"smooth_raw"), for: .normal)
            smoothLabel.text = "Raw"
            break
        }
    }
    
    func setSignalStatus(status: Double) {
        if status <= 10 {
            signalLabel.text = "Excellent"
        } else if status <= 30 {
            signalLabel.text = "Good"
        } else {
            signalLabel.text = "Poor"
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
