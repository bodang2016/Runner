//
//  CoreDataManager.swift
//  Runner
//
//  Created by Bodang on 12/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit
import CoreData

//This class provides the interface for controller to access the Core Data model
class CoreDataManager: NSObject {
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    class func saveLocation(velocity: Double, longitude: Double, latitude: Double, timeStamp: NSDate, startTimeStamp: NSDate) {
        let context = getContext()
        context.perform {
            _ = Location.locationWithRunInfo(velocity: velocity, longitude: longitude, latitude: latitude, timeStamp: timeStamp, startTimeStamp: startTimeStamp, inManagedObjectContext: context)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    class func saveRun(timeStamp: NSDate, duration: Int16, distance: Double, calories: Double) {
        let context = getContext()
        context.perform {
            _ = Run.runWithRunInfo(timeStamp: timeStamp, duration: duration, distance: distance, calories: calories, inManagedObjectContext: context)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    class func deleteRun(timeStamp: NSDate) {
        let context = getContext()
        context.perform {
            _ = Run.deleteRunInfo(timeStamp: timeStamp, inManagedObjectContext: context)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    
//    class func test() {
//        let context = getContext()
//        context.perform {
//            do{
//                var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
//                request.returnsObjectsAsFaults = false
//                if let results = try? context.fetch(request) {
//                    print(results)
//                    print("------------------------------------------------")
//                }
//                request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
//                request.returnsObjectsAsFaults = false
//                if let results = try? context.fetch(request) {
//                    print(results)
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }

}
