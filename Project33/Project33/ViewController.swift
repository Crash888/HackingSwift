//
//  ViewController.swift
//  Project33
//
//  Created by D D on 2017-04-06.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    static var isDirty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "What's that Whistle?"
        
        //  Adds a whistle to the app
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        //  Customize the navigation bar's back button to say "Home" insteed of "What's That Whistle"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

