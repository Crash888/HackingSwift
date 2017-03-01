//
//  GameScene.swift
//  Project14
//
//  Created by D D on 2017-02-28.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    
    //  Controls the rate at which the penguins pop up.
    //  We will increase over time to make the game harder
    var popupTime = 0.85
    
    var gameScore: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
    
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        //  Creates the slots.  4 rows.
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        //  Get the game started.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.createEnemy()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
    
    func createSlot(at position: CGPoint) {
        //  New Slot
        let slot = WhackSlot()
        
        //  Create at the expressed position and add to the scene
        slot.configure(at: position)
        addChild(slot)
        
        //  Update out array for later reference
        slots.append(slot)
    }
    
    func createEnemy() {
        //  Increase the popup time as each enemy is shown.  Making the
        //  game a little faster with each popup
        popupTime *= 0.991
        
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        //  Use random numbers to decide if other penguins should popup too
        if RandomInt(min: 0, max: 12) > 4  { slots[1].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 8  { slots[2].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 10 { slots[3].show(hideTime: popupTime) }
        if RandomInt(min: 0, max: 12) > 11 { slots[4].show(hideTime: popupTime) }
        
        //  Create a random popup delay
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2.0
        let delay = RandomDouble(min: minDelay, max: maxDelay)
        
        //  Keep running itself....showing more penguns
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            self.createEnemy()
        }
    }
}
