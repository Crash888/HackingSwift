//
//  Move.swift
//  Project34
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {

    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
}
