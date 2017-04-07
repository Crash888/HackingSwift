//
//  Board.swift
//  Project34
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

//  Current state of each slot
enum ChipColor: Int {
    case none = 0
    case red
    case black
}

class Board: NSObject {

    static var width = 7
    static var height = 6
    
    //  Array to represent each slot
    var slots = [ChipColor]()
    
    override init() {
        //  Initialize all slots to none
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        
        super.init()
    }
    
    //  Read the chip color given a specified slot
    func chip(inColumn column: Int, row: Int) -> ChipColor {
        return slots[row + column * Board.height]
    }
    
    //  Set the chip color for a specified slot
    func set(chip: ChipColor, in column: Int, row: Int) {
        slots[row + column * Board.height] = chip
    }
    
    //  Return first row number that contains no chips for a
    //  specified column
    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: column, row: row) == .none {
                return row
            }
        }
        
        return nil
        
    }
    
    //  Determine if the player can place a chip in the column
    func canMove(in column: Int) -> Bool {
        return nextEmptySlot(in: column) != nil
    }
    
    //  Add a chip to the board
    func add(chip: ChipColor, in column: Int) {
        if let row = nextEmptySlot(in: column) {
            set(chip: chip, in: column, row: row)
        }
    }
}
