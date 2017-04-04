//
//  ViewController.swift
//  Project28
//
//  Created by D D on 2017-04-04.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
//  Used for TouchID
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        title = "Nothing to see here"
        
        //  Fires when application is not active anymore or user moves to multitasking mode
        //  We will use this to save current state of the secret message and hide it
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //  Check user authorization.  If authorized then show the message else error.
    @IBAction func authenticateTapped(_ sender: UIButton) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self.unlockSecretMessage()
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication Failed", message: "Your fingerprint could not be verified; please try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            //  No touch ID
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)

        }
    }
    
    func adjustForKeyboard(notification: Notification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFranme = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            secret.contentInset = UIEdgeInsets.zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFranme.height, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    //  Get the secret message and display
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        //  Find the message in the Keychain
        if let text = KeychainWrapper.standardKeychainAccess().string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    //  Save our secret message in the keychain
    func saveSecretMessage() {
        
        //  Only do this if the TextView is visible
        if !secret.isHidden {
            _ = KeychainWrapper.standardKeychainAccess().setString(secret.text, forKey: "SecretMessage")
            //  Hides the keyboard
            secret.resignFirstResponder()
            secret.isHidden = true
            title = "Nothing to see here"
            
        }
    }
}

