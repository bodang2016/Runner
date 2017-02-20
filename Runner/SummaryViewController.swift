//
//  SummaryViewController.swift
//  Runner
//
//  Created by Bodang on 18/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import MapKit
import Charts
import CoreData

class SummaryViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var distanceIndicator: UILabel!
    @IBOutlet weak var timeIndicator: UILabel!
    @IBOutlet weak var paceIndicator: UILabel!
    @IBOutlet weak var caloriesIndicator: UILabel!
    
    var runningBrain = RunningBrain()
    
    var selectedItem: NSFetchRequestResult? = nil
    var managedObjectContext: NSManagedObjectContext?
    
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let mapView: MKMapView = MKMapView()
    let velocityChartView = LineChartView()
    
    var route = [CLLocationCoordinate2D]()
    var routeForChart = [Double]()
    
//    let returnButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        indicatorView.layer.shadowColor = UIColor.lightGray.cgColor
        indicatorView.layer.shadowOpacity = 0.8
        indicatorView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        initDistanceIndicator()
        initTimeIndicator()
        initPaceIndicator()
        initCaloriesIndicator()
        setChart(values: routeForChart)
        createPolyline(mapView: mapView, route: route)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for index in 0..<2 {
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            let subView = UIView(frame: frame)
            switch index {
            case 0:
                subView.addSubview(velocityChartView)
                initVelocityChartView(chartView: velocityChartView, view: subView)
                break
            case 1:
                subView.addSubview(mapView)
//                subView.addSubview(returnButton)
                initMapView(mapView: mapView, view: subView)
                break
            default:
                break
            }
            self.scrollView .addSubview(subView)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 2, height: 0)
            pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        }
        
    }
    
    func setChart(values: [Double]) {
        let dataPoints = [String](repeating: "", count:values.count)
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: nil)
        lineChartDataSet.drawValuesEnabled = false
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
        velocityChartView.data = lineChartData
        velocityChartView.drawGridBackgroundEnabled = false
        velocityChartView.setScaleEnabled(false)
        velocityChartView.leftAxis.axisMinimum = 0
        velocityChartView.rightAxis.drawLabelsEnabled = false
        velocityChartView.rightAxis.drawGridLinesEnabled = false
        velocityChartView.legend.enabled = false
        velocityChartView.xAxis.drawGridLinesEnabled = false
        velocityChartView.chartDescription?.text = ""
        velocityChartView.xAxis.drawLabelsEnabled = false
        velocityChartView.animate(yAxisDuration: 3)
    }
    
    func initMapView(mapView: MKMapView, view: UIView) {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = .standard
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = true;
        let constraintMapViewPosX: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraintMapViewPosY: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let constraintMapViewWidth: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let constraintMapViewHeight: NSLayoutConstraint = NSLayoutConstraint(item: mapView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraints([constraintMapViewPosX, constraintMapViewPosY, constraintMapViewWidth, constraintMapViewHeight])
        mapView.delegate = self
    }
    
    func initVelocityChartView(chartView: LineChartView, view: UIView) {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        let constraintChartViewPosX: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let constraintChartViewPosY: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let constraintChartViewWidth: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let constraintChartViewHeight: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraints([constraintChartViewPosX, constraintChartViewPosY, constraintChartViewWidth, constraintChartViewHeight])
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    
    func initDistanceIndicator() {
        if let dataSet = selectedItem as? NSManagedObject {
            distanceIndicator.text = String(describing: dataSet.value(forKey: "distance")!)
        }
       
    }
    
    func initTimeIndicator() {
        if let dataSet = selectedItem as? NSManagedObject {
            let duration = dataSet.value(forKey: "duration")! as! Int16
            let minutes = UInt8(duration / 60)
            let seconds = UInt8(duration % 60)
            
            let minutesString = String(format: "%02d", minutes)
            let secondsString = String(format: "%02d", seconds)
            timeIndicator.text = "\(minutesString):\(secondsString)"
        }
    }
    
    func initPaceIndicator() {
        if let dataSet = selectedItem as? NSManagedObject {
            var averageVelocity = 0.0
            let locationSet = dataSet.objectIDs(forRelationshipNamed: "locations")
            if let context = managedObjectContext {
                for location in locationSet {
                    routeForChart.append(context.object(with: location).value(forKey: "velocity") as! Double)
                    route.append(CLLocationCoordinate2D(latitude: context.object(with: location).value(forKey: "latitude") as! CLLocationDegrees, longitude: context.object(with: location).value(forKey: "longitude") as! CLLocationDegrees))
                    averageVelocity += context.object(with: location).value(forKey: "velocity") as! Double
                }
            }
            averageVelocity = averageVelocity / Double(locationSet.count)
            let paceSmoothInMinute = runningBrain.calculatePaceRate(Velocity: averageVelocity)["minute"]!
            let paceSmoothInSecond = runningBrain.calculatePaceRate(Velocity: averageVelocity)["second"]!
            let paceSmoothInMinuteNorm = String(format:"%02d",paceSmoothInMinute)
            let paceSmoothInSecondNorm = String(format:"%02d",paceSmoothInSecond)
            let paceStr = "\(paceSmoothInMinuteNorm):\(paceSmoothInSecondNorm)"
            paceIndicator.text = paceStr
        }
    }
    
    func initCaloriesIndicator() {
        if let dataSet = selectedItem as? NSManagedObject {
            caloriesIndicator.text = String(describing: dataSet.value(forKey: "calories")!)
        }
    }
    
    func createPolyline(mapView: MKMapView, route: [CLLocationCoordinate2D]) {
        let geodesic = MKGeodesicPolyline(coordinates: route, count: route.count)
        self.mapView.add(geodesic)
            UIView.animate(withDuration: 1.5, animations: { () -> Void in
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region1 = MKCoordinateRegion(center: route.first!, span: span)
                self.mapView.setRegion(region1, animated: true)
            })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.init(red: 24/255, green: 128/255, blue: 251/255, alpha: 1.0)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
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
