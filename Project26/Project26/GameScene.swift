//
//  GameScene.swift
//  Project26
//
//  Created by D D on 2017-03-27.
//  Copyright © 2017 D D. All rights reserved.
//

import CoreMotion
import SpriteKit
import GameplayKit

//  Used for the three bitmasks.  (Category, collision adn contactTest)
enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    var player: SKSpriteNode!

    //  Used to test in simulator to simulate ball movement
    var lastTouchPosition: CGPoint!
    
    //  For device tilting
    var motionManager: CMMotionManager!
    
    //  Track the score
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        
        //  Background image
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //  Score label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
        
        //  Turn off gravity.
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //  Start the accelerometer.
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        physicsWorld.contactDelegate = self
        
        loadLevel()
        
        createPlayer()
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        
        //  First check if the game is over.  If it is then just return
        guard isGameOver == false else { return }
        
        #if (arch(i386) || arch(x86_64))
            //  Change the gravity based on our touch position compared to the player's
            //  current position  (use for simulator only).
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            //  Get the accelerometer data, if available, and change the gravity based on 
            //  the results
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }
    
    //  Load a game level.  Setup screen load sprites, etc
    func loadLevel() {
        
        //  Build the level scene
        //  Using a text file that provides the layout.  Map the text file to the screen.
        if let levelPath = Bundle.main.path(forResource: "level1", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath) {
                let lines = levelString.components(separatedBy: "\n")
                
                //  Go through each character of the text file and translate each letter
                //  to its appropriate scene component
                for (row, line) in lines.reversed().enumerated() {
                    for (column, letter) in line.characters.enumerated() {
                        let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                        
                        if letter == "x" {
                            //  load wall
                            let node = SKSpriteNode(imageNamed: "block")
                            node.position = position
                            
                            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                            node.physicsBody!.categoryBitMask = CollisionTypes.wall.rawValue
                            //  wall is fixed
                            node.physicsBody!.isDynamic = false
                            addChild(node)
                        } else if letter == "v" {
                            //  load vortex
                            let node = SKSpriteNode(imageNamed: "vortex")
                            node.name = "vortex"
                            node.position = position
                            //  Causes vortex to spin forever
                            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody!.isDynamic = false
                            
                            node.physicsBody!.categoryBitMask = CollisionTypes.vortex.rawValue
                            //  Notify me when player and vortex touch
                            node.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
                            node.physicsBody!.collisionBitMask = 0
                            
                            addChild(node)
                            
                        } else if letter == "s" {
                            //  load star
                            let node = SKSpriteNode(imageNamed: "star")
                            node.name = "star"
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody!.isDynamic = false
                            
                            node.physicsBody!.categoryBitMask = CollisionTypes.star.rawValue
                            node.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
                            node.physicsBody!.collisionBitMask = 0
                            
                            node.position = position
                            
                            addChild(node)
                            
                        } else if letter == "f" {
                            //  load finish flag
                            let node = SKSpriteNode(imageNamed: "finish")
                            node.name = "finish"
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody!.isDynamic = false
                            
                            node.physicsBody!.categoryBitMask = CollisionTypes.finish.rawValue
                            node.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
                            node.physicsBody!.collisionBitMask = 0
                            
                            node.position = position
                            
                            addChild(node)
                        }
                    }
                }
            }
        }
        
    }
    
    //  Create the player sprite and give it some properties
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        //  Stop sprite rotation
        player.physicsBody!.allowsRotation = false
        //  Adds friction to movement
        player.physicsBody!.linearDamping = 0.5
        
        player.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody!.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody!.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
    }
    
    //  To handle the collisions in the physics world
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == player {
            playerCollided(with: contact.bodyB.node!)
        } else if contact.bodyB.node == player {
            playerCollided(with: contact.bodyA.node!)
        }
    }
    
    //  Handle the collisions.
    func playerCollided(with node: SKNode) {
        
        //  For the vortex we need to a) stop the ball since it is being
        //  sucked into the vortex  b) simulate the 'sucking in' c) remove 
        //  the ball from the game d) re-create the ball and enable control 
        //  again
        if node.name == "vortex" {
            player.physicsBody!.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [unowned self] in
                self.createPlayer()
                self.isGameOver = false
            }
        } else if node.name == "star" {
            //  Star was hit then remove from scene and increment score
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            //  load next level
        }
    }
}
