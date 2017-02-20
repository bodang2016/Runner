//
//  Location+CoreDataProperties.swift
//  Runner
//
//  Created by Bodang on 13/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var velocity: Double
    @NSManaged public var run: Run?

}
