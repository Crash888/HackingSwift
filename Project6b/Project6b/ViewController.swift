//
//  ViewController.swift
//  Project6b
//
//  Created by D D on 2017-01-17.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.backgroundColor = UIColor.red
        label1.text = "THESE"
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = UIColor.cyan
        label2.text = "ARE"
        
        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = UIColor.yellow
        label3.text = "SOME"
        
        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = UIColor.green
        label4.text = "AWESOME"
        
        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.backgroundColor = UIColor.orange
        label5.text = "LABELS"
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)

        /*
        let viewsDictionary = ["label1": label1,
                               "label2": label2,
                               "label3": label3,
                               "label4": label4,
                               "label5": label5]
        
        
        //  VFL - Visual Format Language
        //  H:|label1| - means Horizontal layout '|' means edge of view
        //       so this means I want label1 to go from edge to edge in my view
        //  Of course it does not know what 'label1' is so we map it to our dictionary
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label1]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label2]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label3]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label4]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label5]|", options: [], metrics: nil, views: viewsDictionary))
        
        //  Now the vertical view
        //  V:|[label1]-[label2]-....|
        //     V = vertical constraint
        //     the '-' symbol means space.  Default is 10 points but can be customized
        //   Notice no '|' at the end.  we will just let the last label float free at the bottom.
        //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1]-[label2]-[label3]-[label4]-[label5]", options: [], metrics: nil, views: viewsDictionary))
        
        //  New Vertical constraint.
        //  (==88) - means labels are 88 high
        //  (>=10) - for the bottom layout space
        //  @999 - the priority of the constraint
        let metrics = ["labelHeight": 88]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
        */
        
        //  Using anchors
        
        //  Used to store the previous label iterated
        var previous: UILabel!
        
        for label in [label1, label2, label3, label4, label5] {
            label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 88).isActive = true
            
            if previous != nil {
                //  we have a previous label so we can create a constraint
                label.topAnchor.constraint(equalTo: previous.bottomAnchor).isActive = true
            }
            
            //  Set previous label to current label
            previous = label
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}

