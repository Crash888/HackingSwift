//
//  ViewController.swift
//  Project32
//
//  Created by D D on 2017-04-06.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import SafariServices

//  For use with CoreSpotlight
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController {

    var projects = [[String]]()
    
    var favorites = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView, key-value observing"])
        projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators."])
        
        //  Get the current favorites list from User Defaults, if available
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        
        //  Enable the tableview for updating (to allow us to select for favorites)
        tableView.isEditing = true
        //  Typically you are not allowed to tap the cell anmore.  We still need to
        //  so set the property below.
        tableView.allowsSelectionDuringEditing = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        
        print("Stuff: \(project[0]): \(project[1])")
        cell.textLabel?.attributedText = makeAttributedString(title: project[0], subTitle: project[1])
        
        //  Set this favorite checkmark
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
        
    }
    
    //  Set up either an insert or delete icon based on whether the row has been favorited.
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if favorites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }
    
    //  This function handles the selection of the editing icon on the left (either to favorite or unfavorite the project)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //  Inserting a new favorite?  or deleting one?
        if editingStyle == .insert {
            //  New favorite?
            //  Add to array
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            //  Get rid of the favorite
            if let index = favorites.index(of: indexPath.row) {
                favorites.remove(at: index)
                deIndex(item: indexPath.row)
            }
        }
        
        //  Update UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    //  This and the next function tells the table view to automatically figure out cell
    //  size based on the text
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //  Go to the HWS tutorial page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    func makeAttributedString(title: String, subTitle: String) -> NSAttributedString {
        
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline), NSForegroundColorAttributeName: UIColor.purple]
        let subTitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subTitleString = NSMutableAttributedString(string: subTitle, attributes: subTitleAttributes)
        
        titleString.append(subTitleString)
        
        return titleString
    }

    //  Opens up a Safari browser where the tutorial is located
    func showTutorial (_ which: Int) {
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true)
        }
    }
    
    //  For handling a favorite added
    //  Deals with CoreSpotlight logic
    func index(item: Int) {
        
        //  Get the project
        let project = projects[item]
        
        //  Setup the searchble set.
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        //  Create a searchable item based on a unique ID, which is our project number
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        
        //  Items have a default expiration of one month.  This extends that.
        item.expirationDate = Date.distantFuture
        //  Index the item
        CSSearchableIndex.default().indexSearchableItems([item]) { (error) in
            if let error = error {
                print ("Indexing error: \(error.localizedDescription)")
            } else {
                print ("Search item successfully indexed!")
            }
        }
    }
    
    //  Favorite removed logic for CoreSpotlight
    func deIndex(item: Int) {
        
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { (error) in
            if let error = error {
                print ("Deindexing error: \(error.localizedDescription)")
            } else {
                print ("Search item successfully removed!")
            }
        }
        
    }
}

