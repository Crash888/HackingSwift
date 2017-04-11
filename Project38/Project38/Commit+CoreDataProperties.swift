//
//  Commit+CoreDataProperties.swift
//  Project38
//
//  Created by D D on 2017-04-10.
//  Copyright © 2017 D D. All rights reserved.
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var sha: String
    @NSManaged public var url: String

}