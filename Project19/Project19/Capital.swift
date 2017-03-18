//
//  Capital.swift
//  Project19
//
//  Created by D D on 2017-03-17.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        
        self.title = title
        self.coordinate = coordinate
        self.info = info
    
    }
}
