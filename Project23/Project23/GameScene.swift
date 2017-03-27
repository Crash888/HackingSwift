//
//  GameScene.swift
//  Project23
//
//  Created by D D on 2017-03-27.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer!
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.black
        
        starField = SKEmitterNode(fileNamed: "Starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        
        //  Simulate the emitter in use for 10 seconds prior to display
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        //  Setup the player
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        
        //  By setting this we create per-pixel collision detection with player
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        //  No gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //  Set timer to create an enemy every 0.35 seconds
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        //  Set a boundary on the y-axis so player cannot go off screen
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    //  Contact has been detected between player and debris.  Game is over
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //  Get rid of objects that are off the screen
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    func createEnemy() {
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        let randomDistribution = GKRandomDistribution(lowestValue: 50, highestValue: 736)
        
        //  Create the enemy
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        sprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        addChild(sprite)
        
        //  Same categoryBitMask as the player to detect collision.  func didBegin(contact:) is called
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        
    }
}
