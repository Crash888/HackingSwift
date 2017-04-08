//
//  ViewController.swift
//  Project34
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var columnButtons: [UIButton]!
    
    //  Array for each column and array of all columns
    var placedChips = [[UIView]]()
    var board: Board!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //  Populate the array with empty arrays
        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        
        //  Initialize the board
        resetBoard()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //  Drop a chip onto the board
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            continueGame()
        }
    }

    func resetBoard() {
        board = Board()
        
        //  Show the correct title in the UI
        updateUI()
        
        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }
    
    //  Place a chip on the board
    func addChip(inColumn column: Int, row: Int, color: UIColor) {
        let button = columnButtons[column]
        //  Board can fit up to 6 chips per column
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        if placedChips[column].count < row + 1 {
            
            //  Create a new chip
            let newChip = UIView()
            newChip.frame = rect
            newChip.isUserInteractionEnabled = false
            newChip.backgroundColor = color
            
            //  This gives the chip the circle shape
            newChip.layer.cornerRadius = size / 2
            newChip.center = positionForChip(inColumn: column, row: row)
            //  Gets the chip to start at the botom of the screen
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            view.addSubview(newChip)
            
            //  Animates the chip falling from the top to its set center position
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { 
                newChip.transform = CGAffineTransform.identity
            })
            
            placedChips[column].append(newChip)
        }
        
    }
    
    //  Returns the center position where the chip should be placed
    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        //  Get the button for the column
        let button = columnButtons[column]
        //  Calculate the button size
        let size = min(button.frame.width, button.frame.height / 6)
        
        //  Horizontal center of column
        let xOffset = button.frame.midX
        //  Gets bottom of button column and subtracts half chip size
        //  to get center of the chip
        var yOffset = button.frame.maxY - size / 2
        //  Now multiply by the row
        yOffset -= size * CGFloat(row)
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    //  Update the UI to show who's turn it is
    func updateUI () {
        title = "\(board.currentPlayer.name)'s turn"
    }
    
    //  Call after each move to determine state
    func continueGame() {
        
        //  Optional tiotle string
        var gameOverTitle: String? = nil
        
        //  Update the title if it is game over or the board is full
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else if board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        //  If we populated the title then the game is over
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            return
        }
        
        //  If we are still here then the game is still on and
        //  we now switch players
        board.currentPlayer = board.currentPlayer.opponent
        
        updateUI()
    }
}

