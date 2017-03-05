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
        
        //  Setup notification to adjust the keyboard when the text gets too close
        //  Observer both the WillHide and WillChangeFrame events to deal with this
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
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

    func done() {
        // Return any edited content to the host app.
        
        //  In our case we are returning the text the user typed into the UITextView
        
        //  NSExtensionItem to host our items
        let item = NSExtensionItem()
        
        //  New Dictionary to hold our items (in this case 1 item....our text
        let argument: NSDictionary = ["customJavaScript": script.text]
        
        //  Now put our dictionary in another special dictionary that will pass our dictionary
        //  back to the JS finalize method
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        
        //  Place that finalize dictionary into a NSItemProvider as its attachments
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        //  Now return the items
        self.extensionContext!.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    
    //  Adjust the frame so the text is not covered by the keyboard
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        //  This tells us the frame of the keyboard after animation complete
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        //  Convert the keyboard frame to our view's co-ordinates
        //  Needed because rotation is not factored into the frame.  The convert method fixes that
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        
        //  Indent the edges of the textView so it appears to take up less space even though 
        //  the constraints are still to the edge of the view
        if notification.name == Notification.Name.UIKeyboardWillHide {
            script.contentInset = UIEdgeInsets.zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        //  Make the textView scroll so the text entry cursor is visible
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

}
