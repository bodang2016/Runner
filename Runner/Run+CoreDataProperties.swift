//
//  Run+CoreDataProperties.swift
//  Runner
//
//  Created by Bodang on 13/02/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import Foundation
import CoreData


extension Run {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Run> {
        return NSFetchRequest<Run>(entityName: "Run");
    }

    @NSManaged public var distance: Double
    @NSManaged public var duration: Int16
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var calories: Double
    @NSManaged public var locations: NSOrderedSet?

}

// MARK: Generated accessors for locations
extension Run {

    @objc(insertObject:inLocationsAtIndex:)
    @NSManaged public func insertIntoLocations(_ value: Location, at idx: Int)

    @objc(removeObjectFromLocationsAtIndex:)
    @NSManaged public func removeFromLocations(at idx: Int)

    @objc(insertLocations:atIndexes:)
    @NSManaged public func insertIntoLocations(_ values: [Location], at indexes: NSIndexSet)

    @objc(removeLocationsAtIndexes:)
    @NSManaged public func removeFromLocations(at indexes: NSIndexSet)

    @objc(replaceObjectInLocationsAtIndex:withObject:)
    @NSManaged public func replaceLocations(at idx: Int, with value: Location)

    @objc(replaceLocationsAtIndexes:withLocations:)
    @NSManaged public func replaceLocations(at indexes: NSIndexSet, with values: [Location])

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSOrderedSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSOrderedSet)

}
