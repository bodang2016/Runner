//
//  SettingViewController.swift
//  Runner
//
//  Created by Bodang on 20/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let genderConstant = "KEY_GENDER"
    let ageConstant = "KEY_AGE"
    let weightConstant = "KEY_WEIGHT"
    let smoothConstant = "KEY_SMOOTH"
    let minAge = 1.0
    let maxAge = 125.0
    let secondPerYear = 31536000.0
    let defaults = UserDefaults.standard
    var AGE: Date?
    var WEIGHT: Double?
    let sliderStep: Float = 3
    
    @IBOutlet weak var genderIndicator: UILabel!
    @IBOutlet weak var ageIndicator: UILabel!
    @IBOutlet weak var weightIndicator: UILabel!
    @IBOutlet weak var smoothSlider: UISlider!
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func smoothSlider(_ sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: true)
        self.defaults.set(sender.value, forKey: self.smoothConstant)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPreference()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        if indexPath.row == 1 && indexPath.section == 0 {
            let alertController:UIAlertController=UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.width - 20, height: 200))
            datePicker.locale = NSLocale(localeIdentifier: "en_UK") as Locale
            datePicker.datePickerMode = UIDatePickerMode.date
            datePicker.date = NSDate() as Date
            datePicker.maximumDate = Date(timeIntervalSinceNow: -minAge * secondPerYear)
            datePicker.minimumDate = Date(timeIntervalSinceNow: -maxAge * secondPerYear)
            if let age = AGE {
                datePicker.setDate(age, animated: true)
            }
            alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default){
                (alertAction)->Void in
                let year: Double = Double(Date().timeIntervalSince(datePicker.date).description)! / self.secondPerYear
                self.ageIndicator.text = Int(year).description
                let dateData = NSKeyedArchiver.archivedData(withRootObject: datePicker.date)
                self.defaults.set(dateData, forKey: self.ageConstant)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler:nil))
            alertController.view.addSubview(datePicker)
            self.present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 0 && indexPath.section == 0 {
            let alertController:UIAlertController=UIAlertController(title: "Choice your gender", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            alertController.addAction(UIAlertAction(title: "Male", style: UIAlertActionStyle.default){
                (alertAction)->Void in
                self.genderIndicator.text = "Male"
                self.defaults.set("Male", forKey: self.genderConstant)
            })
            alertController.addAction(UIAlertAction(title: "Female", style: UIAlertActionStyle.default){
                (alertAction)->Void in
                self.genderIndicator.text = "Female"
                self.defaults.set("Female", forKey: self.genderConstant)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler:nil))
            self.present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 2 && indexPath.section == 0 {
            let alertController:UIAlertController=UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let weightPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.width - 20, height: 200))
            weightPicker.delegate = self
            weightPicker.dataSource = self
            if let weight = WEIGHT {
                let weightInt: Int = Int(weight)
                weightPicker.selectRow((weightInt - 20), inComponent: 0, animated: true)
                if weight - Double(weightInt) != 0 {
                    weightPicker.selectRow(1, inComponent: 1, animated: true)
                }
            }
            alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default){
                (alertAction)->Void in
                var weight = Double(weightPicker.selectedRow(inComponent: 0)) + 20.0
                weight += Double(weightPicker.selectedRow(inComponent: 1)) / 2.0
                self.weightIndicator.text = "\(weight) Kg"
                self.defaults.set(weight, forKey: self.weightConstant)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler:nil))
            alertController.view.addSubview(weightPicker)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func loadPreference() {
        if let genderValue = defaults.string(forKey: genderConstant) {
            genderIndicator.text = genderValue
        }
        if let ageValue = defaults.data(forKey: ageConstant) {
            let date = NSKeyedUnarchiver.unarchiveObject(with: ageValue) as? Date
            let year: Double = Double(Date().timeIntervalSince(date!).description)! / self.secondPerYear
            ageIndicator.text = Int(year).description
            AGE = date
        }
        if let weightValue = defaults.string(forKey: weightConstant) {
            weightIndicator.text = "\(weightValue) Kg"
            WEIGHT = Double(weightValue)
        }
        if let smoothValue = defaults.string(forKey: smoothConstant) {
            smoothSlider.setValue(Float(smoothValue)!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let integer: Int = Int(20.0 + Double(row))
            return integer.description
        } else if component == 1 {
            if row == 0 {
                return 0.description
            } else if row == 1 {
                return 0.5.description
            } else {
                return nil
            }
        } else {
            if row == 0 {
                return "Kg"
            } else {
                return nil
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 181
        } else if component == 1 {
            return 2
        } else {
            return 1
        }
    }

}
