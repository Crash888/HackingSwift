//
//  WhackSlot.swift
//  Project14
//
//  Created by D D on 2017-02-28.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {

    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    //  Works like an initializer.  However, it is not "init"
    //  in order to bypass Swift's 'required init' rules
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        //  Create a crop node and position it slightly higher 
        //  than the slot
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        //  Make sure it is in front of the other nodes
        cropNode.zPosition = 1
        
        //  Set the mask so the peguins are invisible
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        //  Create the penguin.  Make sure it is below the hole to start with
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
        
        //  Note the hierarchy.  charNode added to cropNode.  cropNode added to slot
    }
    
    func show(hideTime: Double) {
        
        //  If it is already visible then don't show again
        if isVisible { return }
        
        //  Move the penguin and set the vars
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        //  Good penguins only one third of the time.
        if RandomInt(min: 0, max: 2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        //  Hide the penguin after a little while
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [unowned self] in
            self.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        
        //  Run the above in sequence
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
    }
}
