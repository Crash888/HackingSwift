//
//  GradientView.swift
//  Project37
//
//  Created by D D on 2017-04-10.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {

    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    //  Provides the type of layer we want for drawing
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }

}
