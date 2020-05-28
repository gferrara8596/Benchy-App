//
//  Coordinate+CoreDataProperties.swift
//  benchy WatchKit Extension
//
//  Created by Loris Scandurra on 21/01/2020.
//  Copyright © 2020 Loris Scandurra. All rights reserved.
//
//

import Foundation
import CoreData


extension Coordinate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coordinate> {
        return NSFetchRequest<Coordinate>(entityName: "Coordinate")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var count: Int64
    @NSManaged public var assetType: Int64

}
