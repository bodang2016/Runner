//
//  Run+CoreDataClass.swift
//  Runner
//
//  Created by Bodang on 12/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import Foundation
import CoreData


public class Run: NSManagedObject {
    class func runWithRunInfo(timeStamp: NSDate, duration: Int16?, distance: Double?, calories: Double?, inManagedObjectContext context: NSManagedObjectContext) -> Run? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
        request.predicate = NSPredicate(format: "timeStamp = %@", timeStamp)
        if let run = (try? context.fetch(request))?.first as? Run {
            if duration != nil {
                run.duration = duration!
            }
            if distance != nil {
                run.distance = distance!
            }
            if calories != nil {
                run.calories = calories!
            }
            return run
        } else if let run = NSEntityDescription.insertNewObject(forEntityName: "Run", into: context) as? Run {
            run.timeStamp = timeStamp
            return run
        }
        return nil
    }
    var sectionByDay: String{
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,YYYY"
            return dateFormatter.string(from: self.timeStamp as! Date)
        }
    }
}
