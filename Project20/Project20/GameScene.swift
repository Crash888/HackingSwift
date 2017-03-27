//
//  GameScene.swift
//  Project20
//
//  Created by D D on 2017-03-17.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer!
    var fireworks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score: Int = 0 {
        didSet {
            
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //  Deal with fireworks that were not destroyed
        //  Loop through the array backwards because removing an items
        //  causes the other items to be resequenced.
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    //  Find if the touch intersected any fireworks.  If so, then change them
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        //  Get location and any nodes at the location
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            
            //  Only need SpriteNodes
            if node is SKSpriteNode {
                let sprite = node as! SKSpriteNode
                
                //  If it is a firework then change the name so it will not be
                //  found again.  Also, change the colour to white
                if sprite.name == "firework" {
                    
                    for parent in fireworks {
                        let firework = parent.children[0] as! SKSpriteNode
                        
                        if firework.name == "selected" && firework.color != sprite.color {
                            firework.name = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                    
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                }
            }
        }
    }
    
    func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch GKRandomSource.sharedRandom().nextInt(upperBound: 4) {
        case 0:
            //  five fireworks straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            //  left to right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            //  right to left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        
        //  Create the firework at the specified location
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        //  Create the rocket sprite and add it to the container
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        node.addChild(firework)
        
        //  Randomize the firework colour
        switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
        case 0:
            firework.color = .cyan
            //  Firework image is white but colorBlendFactor = 1 makes it appear cyan
            firework.colorBlendFactor = 1
        case 1:
            firework.color = .green
            firework.colorBlendFactor = 1
        case 2:
            firework.color = .red
            firework.colorBlendFactor = 1
        default:
            break
        }
        
        //  Now create the path that the firework will travel
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        //  Create the action to have firework follow the path
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        //  Create flying particles behind the rocket
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        //  Add firework to array and the scene
        fireworks.append(node)
        addChild(node)
        
    }
    
    func explode(firework: SKNode) {
        
        //  Create explosion where firework is.
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = firework.position
        addChild(emitter)
        
        //  Remove the firework from the scene
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            let firework = fireworkContainer.children[0] as! SKSpriteNode
            
            //  Blow up all the selected fireworks
            if firework.name == "selected" {
                
                //destroy the firework
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            //  nothing
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
}
