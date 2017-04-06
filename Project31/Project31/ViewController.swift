//
//  ViewController.swift
//  Project31
//
//  Created by D D on 2017-04-04.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    //  Track the current active WebView
    //  It is weak because user can delete the view at any time
    weak var activeWebView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    func addWebView() {
        
        //  Create new WebView
        let webView = UIWebView()
        webView.delegate = self
        
        //  Add it to the StackView.
        //  Note: To add to stackview always use addArrangedSubview and not addSubview()
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.loadRequest(URLRequest(url: url))
        
        //  Create border around each web view to help identify the current
        //  active web view
        webView.layer.borderColor = UIColor.blue.cgColor
        //  Handle the selecting of a web view
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
    }
    
    func deleteWebView() {
    
        //  safely unwrap the webView
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.index(of: webView) {
                //  The current webView has been found.  Now remove it.
                stackView.removeArrangedSubview(webView)
                
                //  Also, remove from the view hierarchy.  Very important.
                //  Things removed from the StackView' s arranged sub views
                //  are just hidden.  WQe do not want a memory leak so we
                //  add this line to destroy the web view
                webView.removeFromSuperview()
                
                //  No web views left
                if stackView.arrangedSubviews.count == 0 {
                    //  Go back to default UI
                    setDefaultTitle()
                } else {
                    //  We have at least one web view after the delete
                    //  Now logic to highlight another sub view
                    
                    //  Convert the deleted web view's index to an Int
                    var currentIndex = Int(index)
                    
                    //  So, if the deleted view was the last one...then go back one
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    //  Now get the new one and select it
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? UIWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    func selectWebView(_ webView: UIWebView) {
        
        //  First change border to zero for all web views
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        //  Chnage border to 3 just for the active web view
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    //  When user taps the screen set the selected web view as active
    func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? UIWebView {
            selectWebView(selectedWebView)
        }
    }
    
    //  Set this up so the built in web view gesture recognizers work together with our gesture recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //  When user hits return then try to open the URL in the webview and 
    //  then resignFirstResponder to make keyboard disappear
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.loadRequest(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    //  Change the stackvew display based on size classes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    
    //  Grab the title from the page and put it in the page title
    func updateUI(for webView: UIWebView) {
        title = webView.stringByEvaluatingJavaScript(from: "document.title")
        addressBar.text = webView.request?.url?.absoluteString ?? ""
    }
    
    //  When the new page loads, if it is the active page then get the title
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
}

