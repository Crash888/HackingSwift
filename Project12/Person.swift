//
//  Person.swift
//  Project12
//
//  Created by D D on 2017-01-22.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

//  NSCoding used for encoding and decoding the data
//  NSCoding requires your class to inherit from NSObject to work
class Person: NSObject, NSCoding {

    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    //  For loading up the objects
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        image = aDecoder.decodeObject(forKey: "image") as! String
    }
    
    //  For saving the objects
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(image, forKey: "image")
    }
}
