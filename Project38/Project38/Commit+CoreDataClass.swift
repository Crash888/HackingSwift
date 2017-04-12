//
//  Commit+CoreDataClass.swift
//  Project38
//
//  Created by D D on 2017-04-10.
//  Copyright © 2017 D D. All rights reserved.
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called")
    }

}
