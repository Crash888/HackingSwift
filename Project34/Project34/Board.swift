//
//  Board.swift
//  Project34
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import GameplayKit

//  Current state of each slot
enum ChipColor: Int {
    case none = 0
    case red
    case black
}

class Board: NSObject, GKGameModel {

    static var width = 7
    static var height = 6
    
    //  Array to represent each slot
    var slots = [ChipColor]()
    
    var currentPlayer: Player
    
    
    //  To conform to the GKModelProtocol
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    override init() {
        
        currentPlayer = Player.allPlayers[0]
        
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
    
    //  Check if the board if full (no more moves left)
    func isFull() -> Bool {
        
        for column in 0 ..< Board.width {
            if canMove(in: column) {
                return false
            }
        }
        
        return true
    }
    
    //  Check if a player has won
    func isWin(for player: GKGameModelPlayer) -> Bool {
        
        let chip = (player as! Player).chip
        
        //  Go through each slot on the board and check for wins
        //  Check for each of the 4 win directions...up, down and the
        //  2 diagonals
        for row in 0 ..< Board.height {
            for col in 0 ..< Board.width {
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 0) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 0, moveY: 1) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 1) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: -1) {
                    return true
                }
            }
        }
        
        return false
    }
    
    //  Given a square and check for a win
    func squaresMatch(initialChip: ChipColor, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        //  Leave early if we cannot win from this position
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        //  Ok, a win is possible.  Time to start checking
        if chip(inColumn: col, row: row) != initialChip { return false }
        if chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }
        
        return true
    }
    
    //  Implementing NSCopying protocol.  Allows you to take
    //  a copy of board
    //  As GameplayKit decides a move by copying the board many times
    //  and then applying a move.  This will be used a lot
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        //  Fill in the board slots
        copy.setGameModel(self)
        return copy
    }
    
    //  Copy across the slot data from the current board
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots
            currentPlayer = board.currentPlayer
        }
    }
    
    //  After the board is setup GameplayKit needs to know what possible
    //  moves are available to be made.  So, this function tells it.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        
        //  Cast the GKGameModelPlayer to Player
        if let playerObject = player as? Player {
            
            //  If someone has one then return no moves available
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
            
            //  Var to hold all valid Move objects
            var moves = [Move]()
            
            //  Go through all the columns to see if a move is allowed
            for column in 0 ..< Board.width {
                if canMove(in: column) {
                    //  Create the new Move object
                    moves.append(Move(column: column))
                }
            }
            
            //  Return the possible moves
            return moves
        }
        
        return nil
    }
    
    //  Now the AI needs to try each move and see what happens
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, in: move.column)
            currentPlayer = currentPlayer.opponent
        }
    }
    
    //  Now the AI wants to know whether the move was good or not
    //  Since, our game has no score but win or lose the move can have
    //  three values.  1000 if move means the AI wins, -1000 if
    //  the opponent wins and 0 for everythng else
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) {
                return 1000
            } else if isWin(for: playerObject.opponent) {
                return -1000
            }
        }
        
        return 0
    }
}
