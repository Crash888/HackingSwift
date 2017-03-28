//
//  GameScene.swift
//  Project26
//
//  Created by D D on 2017-03-27.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit
import GameplayKit

//  Used for the three bitmasks.  (Category, collision adn contactTest)
enum CollisionTypes: UInt32 {
    case playuer = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
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
                for (row, line) in lines.enumerated() {
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
                            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody!.isDynamic = false
                            
                            node.physicsBody!.categoryBitMask = CollisionTypes.vortex.rawValue
                            
                        } else if letter == "s" {
                            //  load star
                        } else if letter == "f" {
                            //  load finish
                        }
                    }
                }
            }
        }
        
    }
}
