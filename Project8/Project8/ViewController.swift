//
//  ViewController.swift
//  Project8
//
//  Created by D D on 2017-01-22.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //  Add all of our buttons to the leeterButtons array.
        //  They are all marked with tag 1001 so they are easily identified
        //  All buttons will call the letterTapped function when tapped
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        
        loadLevel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //  User thinks they have a word and checking to see if it 
    //  is correct
    @IBAction func submitTapped(_ sender: UIButton) {
        
        //  Found a correct answer
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            
            //  Activated buttons are current hidden.  Keep them hidden
            //  and rmove from activated array
            activatedButtons.removeAll()
            
            //  Split ip the answers text string
            //  Find the correct string to change based on the solution index
            //  Replace the current answer text (ie. 7 letters) with the answer
            var splitClues = answersLabel.text!.components(separatedBy: "\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            //  This will tell us if everything has been answered
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well Done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        }
    }
    
    //  User wants to reset choices
    @IBAction func clearTapped(_ sender: UIButton) {
        
        //  Erase current answer
        currentAnswer.text = ""
        
        //  All the buttons selected are now visible again
        for btn in activatedButtons {
            btn.isHidden = false
        }
        
        //  Clear the array
        activatedButtons.removeAll()
        
    }
    
    //  Player tapped a button with some text
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        //  Load the level file
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                
                //  Break the file into lines and randomize
                var lines = levelContents.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                
                //  Now split each line into answer and clue
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    //  Building the clue list
                    clueString += "\(index + 1). \(clue)\n"
                    
                    //  Building the solutions array
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    //  Store each of the word sections
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                    
                }
            }
        }
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //  Randomize the letter bits to make it more difficult
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        
        //  Put the letter bits in the buttons
        if letterBits.count == letterButtons.count {
            for i in 0..<letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }
}

