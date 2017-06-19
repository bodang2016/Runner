//
//  HistoryTableViewCell.swift
//  Runner
//
//  Created by Bodang on 14/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

//This class defines the internal logic of each cell in UITableView
import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    @IBOutlet weak var activityIcon: UIImageView!
    
    var name: String? {
        didSet{
            activityName.text = "\(name!) KM"
        }
    }
    var date: NSDate? {
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, hh:mm a"
            let dateString = dateFormatter.string(from: date as! Date)
            activityDate.text = dateString
        }
    }
    func setCell(name: String, date: NSDate) {
        
    }
    
}
