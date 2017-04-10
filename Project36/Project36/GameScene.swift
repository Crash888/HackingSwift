//
//  GameScene.swift
//  Project36
//
//  Created by D D on 2017-04-08.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    var backgroundMusic: SKAudioNode!
    
    //  Opening screen
    var logo: SKSpriteNode!
    //  GameOver Screen
    var gameOver: SKSpriteNode!
    
    //  Game starts at the logo screen
    var gameState = GameState.showingLogo
    
    override func didMove(to view: SKView) {
        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        createLogos()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        //  The background music
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        switch gameState {
        case .showingLogo:
            gameState = .playing
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                //  player now responds to physics
                self.player.physicsBody?.isDynamic = true
                self.startRocks()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
        
        case .playing:
            //  When the user taps we give the plane a little push upwards each time
            //  First line removes any existing push and the second line applies a
            //  new push.
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            
        case .dead:
            //  When user touches the sceen at game over we will start a new game.
            //  This creates a fresh game scene with simple animation
            let scene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //  Make sure we have a player before proceeding
        guard player != nil else { return }
        
        //  Causes the plane to tilt up or down based on velocity
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        
        player.run(rotate)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //  Did the plane hit the scoring rectangle?  If so, then score a point
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
            run(sound)
            
            score += 1
            
            return
        }
        
        //  Because we are potentially removingFromParent() above we need to test that we have
        //  both objects before continuing
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else { return }
        
        //  Detect plane contacting anythng else.  All collisions result in a crash
        if contact.bodyA.node == player || contact.bodyB.node == player {
            
            //  Blow up the plane
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }
            
            //  Play explosion sound
            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
            run(sound)
            
            gameOver.alpha = 1
            gameState = .dead
            backgroundMusic.run(SKAction.stop())
            
            //  Remove plane and stop everything from moving
            player.removeFromParent()
            speed = 0
        }
    }
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)
        
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        //  This says report if a player 'touches' anything
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        
        //  Default that the player does not respond to physics.  We are on the logo screen
        //  so just have the plane flying straight
        player.physicsBody?.isDynamic = false
        
        //  This says that we should not detect 'collisions' between objects
        //  (ie. nothing should bounce off anything else)
        player.physicsBody?.collisionBitMask = 0
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
        
    }
    
    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height / 2)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
        
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        //  Create two mountain ranges side by side.  This creates the 
        //  effect of continuous movement
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
            addChild(background)
            
            //  duration is speed of the sky movement
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))) , y: groundTexture.size().height / 2)
            
            //  Pixel perfect collision with sprites
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            //  The ground can get hit but it will not move
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)
            
            //  duration is speed of the ground movement
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
    }
    
    //  Control the timing of the rock objects
    func startRocks() {
        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }
        
        //  Launch new rocks every 3 seconds
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    //  Create the rock objects that the plane needs to avoid
    func createRocks() {
        let rockTexture = SKTexture(imageNamed: "rock")
        
        //  Create a top rock and a bottom rock
        //  Top rock if a flipped over version of the rock image
        let topRock = SKSpriteNode(texture: rockTexture)
        
        topRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        topRock.physicsBody?.isDynamic = false
        
        topRock.zRotation = CGFloat.pi
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        
        bottomRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        bottomRock.physicsBody?.isDynamic = false
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        //  Create a sprite after the rocks to detect a player passing the rocks
        //  successfully
        let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height))
        
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        //  Determione the 'safe' range beetween the rocks
        let xPosition = frame.width + topRock.frame.width
        
        let max = Int(frame.height / 3)
        let rand = GKRandomDistribution(lowestValue: -100, highestValue: max)
        let yPosition = CGFloat(rand.nextInt())
        
        //  This value is for the width between the rocks.  Smaller value will
        //  make the game harder
        let rockDistance: CGFloat = 70
        
        //  Position the rocks just off the right edge of the screen
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        
        let endPosition = frame.width + (topRock.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 40)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        
        addChild(scoreLabel)
    }
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
}
