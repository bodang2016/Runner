//
//  Location+CoreDataClass.swift
//  Runner
//
//  Created by Bodang on 12/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import Foundation
import CoreData


public class Location: NSManagedObject {
    class func locationWithRunInfo(velocity: Double, longitude: Double, latitude: Double, timeStamp: NSDate, startTimeStamp: NSDate, inManagedObjectContext context: NSManagedObjectContext) -> Location? {
        if let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context) as? Location {
            location.velocity = velocity
            location.latitude = latitude
            location.longitude = longitude
            location.timeStamp = timeStamp
            location.run = Run.runWithRunInfo(timeStamp: startTimeStamp, duration: nil, distance: nil, calories: nil, inManagedObjectContext: context)
            return location
        }
        return nil
    }
}
