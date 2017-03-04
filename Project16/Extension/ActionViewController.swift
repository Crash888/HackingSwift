//
//  ActionViewController.swift
//  Extension
//
//  Created by D D on 2017-03-03.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!

    var pageTitle = ""
    var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //  ExtensionContext.inputItems contains the data that the paranet app is
        //  sending to the extension
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            
            //  Look for any attachments and pull out the first one
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                
                //  Get the provider to provide us with the item
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    // do stuff
                    let itemDictionary = dict as! NSDictionary
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    
                    //print(javaScriptValues)
                    
                    //  Assign the values from the JavaScript to our vars
                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String
                    
                    //  Set our title to the Web Page title.
                    DispatchQueue.main.async {
                        self.title = self.pageTitle
                    }
                    
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        /*  Code supplied by Xcode
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
                        OperationQueue.main.addOperation {
                            if let strongImageView = weakImageView {
                                if let imageURL = imageURL as? URL {
                                    strongImageView.image = UIImage(data: try! Data(contentsOf: imageURL))
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
