//
//  ViewController.swift
//  Project34
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    @IBOutlet var columnButtons: [UIButton]!
    
    //  Array for each column and array of all columns
    var placedChips = [[UIView]]()
    var board: Board!
    
    //  Holds the AI strategy
    var strategist: GKMinmaxStrategist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //  Populate the array with empty arrays
        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        
        //  Setup the AI Player
        strategist = GKMinmaxStrategist()
        //  Careful with this number as increasing gets exponentially slower
        strategist.maxLookAheadDepth = 7
        //  If more than one move result in a tie score then just
        //  return the first move (as opposed to a random move)
        //  Random best move would be....
        //       strategist.randomSouce = GKARC4RandomSource()
        strategist.randomSource = nil
        
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
        
        //  Feed the board to the AI
        strategist.gameModel = board
        
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
        
        if board.currentPlayer.chip == .black {
            startAIMove()
        }
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
    
    //  Function for AI to find best move.  Could take a while so
    //  we will want to run this on a background thread
    func columnForAIMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        
        return nil
    }
    
    //  AI is ready to make a real move.  Call this on the main thread to make this happen
    func makeAIMove(in column: Int) {
        
        //  Give control back to the user
        //  That is....enable all buttons and remove the spinner
        columnButtons.forEach { $0.isEnabled = true }
        navigationItem.leftBarButtonItem = nil
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            
            continueGame()
        }
    }
    
    //  Call the AI methods to make a move
    func startAIMove() {
        
        //  Disable all buttons while AI is thinking
        columnButtons.forEach { $0.isEnabled = false }
        
        //  Show a spinner to indicate the AI is thinking
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        //  Start with abackground thread to evaluate moves
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            let column = self.columnForAIMove()!
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            //  Make AI take a minimum of 1 second to make a move
            //  Makes it feel a bit better to the real player
            let aiTimeCeiling = 1.0
            let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
            
            //  Now make the real move on the main queue
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: column)
            }
        }
    }
}

