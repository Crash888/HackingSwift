//
//  GameScene.swift
//  Project17
//
//  Created by D D on 2017-03-08.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

//  Decide when bomb should be created
enum ForceBomb {
    case never, always, random
}

//  Ways that enemies can be created
enum SequenceType: Int {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

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
    
    //  Bomb sound effect
    var bombSoundEffect: AVAudioPlayer!
    
    //  Keep track of enemies currently on screen
    var activeEnemies = [SKSpriteNode]()
    
    //  Properties to launch enemies
    var popupTime = 0.9  //  Time to wait between enemies
    var sequence: [SequenceType]!
    var sequencePosition = 0  //  Where we are in the current sequence
    var chainDelay = 3.0  //  Enemy creation time for chain for fastChain
    var nextSequenceQueued = true  //  Let's us know when all enemies destroyed
    
    //  Detect Game Ended
    var gameEnded = false
    
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
        
        //  Initial sequence of tosses to start every game.
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        //  Now add 1001 random sequences to fill up the game
        for _ in 0 ... 1000 {
            let nextSequence = SequenceType(rawValue: RandomInt(min: 2, max: 7))!
            sequence.append(nextSequence)
        }
        
        //  Initial eneny toss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            [unowned self] in
            self.tossEnemies()
        }
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
        
        //  Don't do anything if game has eneded
        if gameEnded {
            return
        }
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        //  Sound effects time
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "enemy" {
                //  got penguin
                
                //  First add an effect over the hit penguin
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                //  Put the emitter right on top of the penguin
                emitter.position = node.position
                addChild(emitter)
                
                //  Clear name so it can't be swiped again
                node.name = ""
                
                //  Now stop the flaaing of the penguin
                node.physicsBody!.isDynamic = false
                
                //  Make the penguin disappear...scale out and fade out together
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                //  Once faded and scaled, remove from the scene
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                //  Run the sequence
                node.run(seq)
                
                //  Add to the score
                score += 1
                
                //  Remove the enemy from the array
                let index = activeEnemies.index(of: node as! SKSpriteNode)!
                activeEnemies.remove(at: index)
                
                //  Sound effect of hitting the penguin
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                //  Got the bomb
                
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.position
                addChild(emitter)
                
                node.name = ""
                
                node.parent?.physicsBody!.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                node.parent!.run(seq)
                
                let index = activeEnemies.index(of: node.parent as! SKSpriteNode)!
                activeEnemies.remove(at: index)
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                
                endGame(triggeredByBomb: true)
            }
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
    
    //  Called for every frame before it is drawn
    override func update(_ currentTime: TimeInterval) {
        
        //  Check if any emenies are off the screen.  If so,
        //  then remove them
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                
                if node.position.y < -140 {
                    
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        
                        if let index = activeEnemies.index(of: node) {
                            activeEnemies.remove(at: index)
                        }
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        
                        if let index = activeEnemies.index(of: node) {
                            activeEnemies.remove(at: index)
                        }
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) {
                    [unowned self] in
                    self.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        //  Count the bombs on screen
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            //  No bombs so sound should stop
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
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
    
    //  Create an enemy to show on screen
    func createEnemy(forceBomb: ForceBomb = .random) {
        
        var enemy: SKSpriteNode
        
        //  Randomly generate enemy type
        var enemyType = RandomInt(min: 0, max: 6)
        
        //  Override the random for specific cases
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            //  bomb
            
            //  New Sprite node to hold bomb and fuse as children
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            //  Create the bomb image and add to container
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            //  Stop any current bomb sound effects
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            
            //  Create new bomb sound effect
            let path = Bundle.main.path(forResource: "sliceBombFuse.caf", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            let sound = try! AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()
            
            //  Now create the fuse and add to the container
            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
            
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        //  position code
        //  Create random position at bottom of screen
        let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128)
        enemy.position = randomPosition
        
        //  Now add angular velocity (ie. spinning speed)
        let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6)) / 2.0
        
        //  Random X Velocity (horizontal movement)
        var randomXVelocity = 0
        
        if randomPosition.x < 256 {
            randomXVelocity = RandomInt(min: 8, max: 15)
        } else if randomPosition.x < 512 {
            randomXVelocity = RandomInt(min: 3, max: 5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -RandomInt(min: 3, max: 5)
        } else {
            randomXVelocity = -RandomInt(min: 8, max: 15)
        }
        
        //  Random Y velocity for flying at different speeds
        let randomYVelocity = RandomInt(min: 24, max: 32)
        
        //  Objects have circular physics body and don't hit each other
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody!.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody!.angularVelocity = randomAngularVelocity
        enemy.physicsBody!.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    //  Throw up an enemy to be sliced
    func tossEnemies() {
        
        //  Don't do anything if game has eneded
        if gameEnded {
            return
        }

        //  Speed everything up a bit with each toss
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            createEnemy()
            
            //  Launch next enemy after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) {
                    [unowned self] in self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) {
                [unowned self] in self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) {
                [unowned self] in self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) {
                [unowned self] in self.createEnemy()
            }
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) {
                [unowned self] in self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) {
                [unowned self] in self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) {
                [unowned self] in self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) {
                [unowned self] in self.createEnemy()
            }
            
        }
        
        sequencePosition += 1
        
        nextSequenceQueued = false
    }
    
    func subtractLife() {
        
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
        
    }
    
    func endGame(triggeredByBomb: Bool) {
        
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
}
