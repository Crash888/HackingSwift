//
//  GameScene.swift
//  Project11
//
//  Created by D D on 2017-02-24.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    //  Is edit mode enabled?
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    //  Like the viewDidLoad method of SpriteKit
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        // Set the SKPhysicsWorld delegate
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            //  Where did the touch happen?
            let location = touch.location(in: self)
            
            /*  Create a simple square box
            let box = SKSpriteNode(color: UIColor.red, size: CGSize(width: 64, height: 64))
            
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            
            box.position = location
            addChild(box)
            */
            
            let objects = nodes(at: location)
            
            //  If the editing label was touched then change editing mode
            //  otherwise do something else
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                
                if editingMode {
                    //  Create a box
                    //  Box will have a height of 16 and random width between 16 and 128
                    //  Rotation is random as well
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody!.isDynamic = false
                    
                    addChild(box)
                } else {
                    //  Create a ball
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    
                    //  Naming the node
                    ball.name = "ball"
                    
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    
                    //  Set TestBitMask to BitMask
                    //  collisionBitMask = "Which nodes should I bump into?"
                    //  collisionTestBitMask =  "Which collisions do you want to know about?"
                    //  Setting equal means "Tell me about every collision"
                    //  Not very efficient but good enough for now
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    
                    //  Ball bounciness
                    ball.physicsBody!.restitution = 0.4
                    
                    //ball.position = location
                    ball.position = CGPoint(x: location.x, y: 760)
                    addChild(ball)
                }
            }
        }
    }
    
    func makeBouncer (at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        
        //  Make sure this object doesn't move when being hit
        bouncer.physicsBody!.isDynamic = false
        addChild(bouncer)

    }
    
    func makeSlot( at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            
            //  Node name for reference later
            slotBase.name = "good"
            
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            
            //  Node name for reference later
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody!.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        //  Action to spin the slot images forever
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
    }
    
    //  Call when ball collides with something
    func collisionBetween(ball: SKNode, object: SKNode) {
        
        //  Destroy the ball if it comes in contact with any of the slots
        if object.name == "good" {
            destroy(ball: ball)
            //  Adjust the player's score
            score += 1
            
        } else if object.name == "bad" {
            destroy(ball: ball)
            
            //  Adjust the player's score
            score -= 1
        }
    }
    
    //  Call when we are done with the ball
    func destroy(ball: SKNode) {
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        //  Remove node from game
        ball.removeFromParent()
    }
    
    //  Part of SKPhysicsContactDelegate
    //  Detects contact.  Make sure one is a ball
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
}
