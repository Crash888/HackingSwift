//
//  GameScene.swift
//  Project17
//
//  Created by D D on 2017-03-08.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    //  Used for the on screen slices
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    //  Store the currently active slice points
    var activeSlicePoints = [CGPoint]()
    
    //  Used for the swoosh audio
    var isSwooshSoundActive = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //  CGVector kind of like CGPoimnt but takes deltas
        //  Adjust gravity down 6 so that objects will stay in the
        //  air a bit longer
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        //  Slow the speed a bit as well to make things move a bit slower
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        //  With new touch we remove all other touches first
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        //  Get touch location and add to array
        if let touch = touches.first {
            let location = touch.location(in: self)
            activeSlicePoints.append(location)
            
            //  Clear the slice shapes
            redrawActiveSlice()
            
            //  Remove any actions associated with slice shapres
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            //  Make slice shape visible
            activeSliceBG.alpha = 1
            activeSliceFG.alpha = 1
        }
    }
    
    //  Find out where the user touched and store the point
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        //  Sound effects time
        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    //  Called when the user finishes touching the screen
    //  Will fade out the slice over 0.25 seconds
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        
    }
    
    //  Called when the touch is system interrupted
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        
        if let touches = touches {
            touchesEnded(touches, with: event)
        }
    }
    
    //  Score label
    func createScore() {
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
    }
    
    //  Life labels
    func createLives() {
        
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            
            addChild(spriteNode)
            
            //  Add the lives images to the array to delete once a player loses
            livesImages.append(spriteNode)
        }
    }
    
    //  Show slices on screen when player swipes
    //  It does the following
    //    1.  Record swipe points
    //    2.  Draw 2 slice shapes making the swipe look like a hot glow
    //    3.  Make sure slices are visible on top
    func createSlices() {
        
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    //  Create a line that connects swipe points
    func redrawActiveSlice() {
        
        //  First check that we have more than two points in the array
        //  if not then leave (as we do not have enough data)
        if activeSlicePoints.count < 2 {
            activeSliceFG.path = nil
            activeSliceBG.path = nil
        }
        
        //  We want a maximum of 12 slice points in the array
        //  make sure to remove the older ones
        while activeSlicePoints.count > 12 {
            //  Index 0 is always the oldest point
            activeSlicePoints.remove(at: 0)
        }
        
        // Start a line at the first point and go through all other points
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        //  Update slice shape paths with our design
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
        
    }
    
    //  For the slicing sound effect
    func playSwooshSound() {
        
        isSwooshSoundActive = true
        
        //  Three swoosh sounds are available.  Randomly choose 1 each time
        let randomNumber = RandomInt(min: 1, max: 3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        //  Play the sound
        run(swooshSound) { [unowned self] in
            self.isSwooshSoundActive = false
        }
    }
    
}
