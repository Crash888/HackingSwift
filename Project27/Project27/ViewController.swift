//
//  ViewController.swift
//  Project27
//
//  Created by D D on 2017-04-04.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        drawRectangle()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func redrawTapped(_ sender: UIButton) {
        
        currentDrawType += 1
        
        if currentDrawType > 5 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerBoard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImageAndText()
        default:
            break
        }
    }

    func drawRectangle() {
        
        //  Create the renderer.  No drawing done here though.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        //  This does the drawing.  ctx = UIGraphicsImageRenerederContext
        let img = renderer.image { ctx in
            //  drawing code...make a rectangle
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            //  Color insde rectangle
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            //  Rectangle edge color
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            //  Width of the stroke
            ctx.cgContext.setLineWidth(10)
            
            //  Add the rectangle to the context to be drawn
            ctx.cgContext.addRect(rectangle)
            //  Finally, draw it!
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        //  Image will be the result of the closure
        imageView.image = img
        
    }
    
    func drawCircle() {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { (ctx) in
            //  Similar to rectangle drawing.  Only difference is call to
            //  .addEllipse instead of .addRectangle
            
            //  Note: Stroke is centered on the path.  This means that stroke width of 10
            //  is chopped to 5 on the edges.  To fix, we can make the shape smaller by the
            //  width of the stroke  
            //  ie. CGRect(x: 0, y: 0, width: 512, height: 512)
            //     change to
            //      CGRect(x: 5, y: 5, width: 502, height: 502)
            let rectangle = CGRect(x: 5, y: 5, width: 502, height: 502)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
        }
        
        imageView.image = img
    }
    
    func drawCheckerBoard() {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { (ctx) in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        //  Fill the box with the current fillColor
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = img
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { (ctx) in
            //  Moves the transformation matrix to the center of the renderer.
            //   By default the the matrix is in the top left corner
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                //  Rotate the matrix
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    //  Creates a square spiral
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { (ctx) in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: CGFloat.pi / 2)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    func drawImageAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { (ctx) in
            
            //  Create a paragraph style for the text.  Set alignment to center
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            //   Create an attributes dictionary to be applied to text
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 36)!, NSParagraphStyleAttributeName: paragraphStyle ]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            string.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = img
    }
}

