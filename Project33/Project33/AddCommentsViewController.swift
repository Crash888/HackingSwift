//
//  AddCommentsViewController.swift
//  Project33
//
//  Created by D D on 2017-04-06.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class AddCommentsViewController: UIViewController, UITextViewDelegate {

    var genre: String!
    
    var comments: UITextView!
    let placeHolder = "If you have any additional comments that might help identify your tune, enter them here."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        
        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(comments)
        
        comments.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        comments.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        comments.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
        comments.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        
    }
    
    func submitTapped() {
        let vc = SubmitViewController()
        vc.genre = genre
        
        if comments.text == placeHolder {
            vc.comments = ""
        } else {
            vc.comments = comments.text
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolder {
            textView.text = ""
        }
    }
}
