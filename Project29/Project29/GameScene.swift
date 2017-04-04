//
//  GameScene.swift
//  Project29
//
//  Created by D D on 2017-04-04.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    //  Need to talk to View Controller but make reference weak so we do not own it
    weak var viewController: GameViewController!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        physicsWorld.contactDelegate = self
        
        createBuildings()
        createPlayers()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if banana != nil {
            if banana.position.y < -1000 {
                banana.removeFromParent()
                banana = nil
                
                changePlayer()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        //  Limit the checking required by ordering the contacts by categoryBitMask
        //  So, building hits banana is the same as banana hits building, etc
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //  Determine type of collision.  Note: we optionally unwrap because a hit could be
        //  nil (ie.  this is called because banana hit building but then another call happens
        //            right after of building hitting banana.  However the banana will already
        //            be destroyed after the first call)
        if let firstNode = firstBody.node {
            if let secondNode = secondBody.node {
                
                if firstNode.name == "banana" && secondNode.name == "building" {
                    bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player1" {
                    destroy(player: player1)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player2" {
                    destroy(player: player2)
                }
            }
        }
        
    }
    func createBuildings() {
        
        //  Starying point to place a building
        //  Just off the screen to make it look a little better
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            //  Building width 80, 120 or 160 and height between 300 and 600
            let size = CGSize(width: RandomInt(min: 2, max: 4) * 40, height: RandomInt(min: 300, max: 600))
            
            //  The +2 give a little space between buildings
            currentX += size.width + 2
            
            //  Create the building
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
            
        }
    }
    
    func createPlayers() {
        
        // Create player 1 and put him on top of a building
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody!.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody!.isDynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        //  Do the same for player 2
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody!.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody!.isDynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)

    }
    
    func launch(angle: Int, velocity: Int) {
        
        //  Calculate how to throw the banana
        //  Velocity
        let speed = Double(velocity) / 10.0
        
        //  Angle.  Convert from degrees to radians
        let radians = deg2rad(degrees: angle)
        
        //  Get rid of any other bananas on the screen already
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        //  Create the new banana
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody!.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody!.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody!.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        //  More precise collision detection.  Can be slower but is more accurate
        banana.physicsBody!.usesPreciseCollisionDetection = true
        addChild(banana)
        
        //  Launch for current player
        if currentPlayer == 1 {
            
            //  Get banana ready to throw
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody!.angularVelocity = -20
            
            //  Now animate player throwing the banana
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            //  Now get the banana moving
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
            
        } else {
            //  Player 2
            //  Get banana ready to throw
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody!.angularVelocity = 20
            
            //  Now animate player throwing the banana
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            //  Now get the banana moving
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
        
        
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180.0
    }
    
    //  Once player is destroyed we will begin a new game after 2 seconds
    func destroy(player: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "hitPlayer")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        banana?.removeFromParent()
        
        //  Everything has been cleaned up.  Start a new game
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
        
            //  Set the vars so the scene can talk to the controller and vice versa
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            //  Make sure losing player always goes first
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            //  Transition time
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(building: BuildingNode, atPoint contactPoint: CGPoint) {
        
        //  Animate banana hitting a building
        //  The convert() method converts the collision contact point to 
        //  the co-ordinates relative to the building node
        //  (ie. bulding at X:200 and collision at X:250 returns X:50 because
        //  it is 50 points into the building node)
        let buildingLocation = convert(contactPoint, to: building)
        building.hitAt(point: buildingLocation)
        
        //  Show an explosion at that point
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        addChild(explosion)
        
        //  Get rid of the banana
        //  Set name to "" in case banana hits two buildings at the same time
        //  It would then explode twice.  This prevents the second collision
        banana.name = ""
        banana?.removeFromParent()
        banana = nil
        
        //  Next player's turn
        changePlayer()
    }
    
}
