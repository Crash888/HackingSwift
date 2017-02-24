//
//  GameScene.swift
//  Project11
//
//  Created by D D on 2017-02-24.
//  Copyright © 2017 D D. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            /*  Create a simple square box
            let box = SKSpriteNode(color: UIColor.red, size: CGSize(width: 64, height: 64))
            
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            
            box.position = location
            addChild(box)
            */
            
            let ball = SKSpriteNode(imageNamed: "ballRed")
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
            
            //  Ball bounciness
            ball.physicsBody!.restitution = 0.4
            
            ball.position = location
            addChild(ball)
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
}
