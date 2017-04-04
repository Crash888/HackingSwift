//
//  BuildingNode.swift
//  Project29
//
//  Created by D D on 2017-04-04.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class BuildingNode: SKSpriteNode {

    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
        
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody!.isDynamic = false
        physicsBody!.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        
        //  Create the CoreGraphics renderer
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { (ctx) in
            
            //  Create the building rectangle and fill it with a random color
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            var color: UIColor
            
            switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            //  Create windows in the building.  Some are on and others are off
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            //  stride() allows you to loop from one number to the next with an interval
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if RandomInt(min: 0, max: 1) == 0 {
                        ctx.cgContext.setFillColor(lightOnColor.cgColor)
                    } else {
                        ctx.cgContext.setFillColor(lightOffColor.cgColor)
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        
        return img
    }

    func hitAt(point: CGPoint) {
        
        //  Identofy where building was hit
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        
        //  Draw the building to start with
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { (ctx) in
            currentImage.draw(at: CGPoint(x: 0, y: 0))
            
            //  Create an ellipse at the collision point  Collision will be 64x64
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            //  Take the ellipse and cut it out of the image
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        //  Save the new building in the current image...ready for the next hit
        currentImage = img
        
        //  Call this to recalculate the per-pixel physics of the new damaged building
        configurePhysics()
    }
}
