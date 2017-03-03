//
//  ViewController.swift
//  Project15
//
//  Created by D D on 2017-03-03.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tap: UIButton!
    
    var imageView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //  Place the penguin image in the middle of a landscape screen
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //  Cycle through a bunch of animations
    @IBAction func tapped(_ sender: UIButton) {
        
        //  Start the animation
        //  First hide the Tap button
        tap.isHidden = true
        
        //  Do the animation and once complete bring the Tap button back
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
            animations: { [unowned self] in
                switch self.currentAnimation {
                case 0:
                    //  Make the view 2x is current size
                    self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                case 1:
                    //  Reset the transform
                    self.imageView.transform = CGAffineTransform.identity
                case 2:
                    //  Move the penguin to the top left corner
                    self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
                case 3:
                    //  Reset the transform
                    self.imageView.transform = CGAffineTransform.identity
                case 4:
                    //  Rotate the penguin
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                case 5:
                    //  Now back to normal again
                    self.imageView.transform = CGAffineTransform.identity
                case 6:
                    //  Fade it out and change the background color
                    self.imageView.alpha = 0.1
                    self.imageView.backgroundColor = UIColor.green
                case 7:
                    //  Now reverse the effects from case 6
                    self.imageView.alpha = 1
                    self.imageView.backgroundColor = UIColor.clear
                default:
                    break
                }
        }) { [unowned self] (finished: Bool) in
            self.tap.isHidden = false
        }
        
        //  Go to the next animation
        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
}

