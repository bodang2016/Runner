//
//  HistoryTableViewController.swift
//  Runner
//
//  Created by Bodang on 14/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import CoreData

//This is the controller class of history view, it provides the Outlet and Action functions for the UI components, this class inherits the CoreDataTableViewController class
class HistoryTableViewController: CoreDataTableViewController {
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet{
            updateUI()
        }
        
    }

    private func updateUI() {
        if let context = managedObjectContext {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
            request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
            //sectionbyday
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            fetchedResultsController = nil
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
        if let activity = fetchedResultsController?.object(at: indexPath) as? Run {
            var title: String?
            var date: NSDate?
            activity.managedObjectContext?.performAndWait ({
                title = String(activity.distance)
                date = activity.timeStamp
            })
//            cell.textLabel?.text = title
            if let activityCell = cell as? HistoryTableViewCell {
                activityCell.name = title
                activityCell.date = date
            }
        }
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if let SummaryVC = destinationVC as? SummaryViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "showSummaryView":
                    if let selectedItem = fetchedResultsController?.fetchedObjects![tableView.indexPathForSelectedRow!.row] {
                        SummaryVC.selectedItem = selectedItem
                    }
                    break;
                default:
                    return
                }
            }
        }
        
    }

}
