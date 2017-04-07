//
//  MyGenresViewController.swift
//  Project33
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresViewController: UITableViewController {

    //  Track a list of genres that the user considers
    //  to have expertise
    var myGenres: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if let savedGenres = defaults.object(forKey: "myGenres")as? [String] {
            myGenres = savedGenres
        } else {
            myGenres = [String]()
        }
        
        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreTableViewController.genres.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let genre = SelectGenreTableViewController.genres[indexPath.row]
        cell.textLabel?.text = genre
        
        //  Put a check mark next to the genres that are in my list
        if myGenres.contains(genre) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedGenre = SelectGenreTableViewController.genres[indexPath.row]
            
            //  Check it if it is not check and vice versa.  Also update the myGenres array
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .none
                
                if let index = myGenres.index(of: selectedGenre) {
                    myGenres.remove(at: index)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //  User wants to save their chosen list of Genres
    func saveTapped() {
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "myGenres")
        
        let database = CKContainer.default().publicCloudDatabase
        
        database.fetchAllSubscriptions { [unowned self] (subscriptions, error) in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID) { (str, error) in
                            if error != nil {
                                let ac = UIAlertController(title: "Error", message: "There was a problem deleting the subscriptions; please try again", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                                
                                print(error!.localizedDescription)
                            }
                        }
                    }
                    
                    //  Now register the updated subscriptions with iCloud
                    for genre in self.myGenres {
                        let predicate = NSPredicate(format: "genre = %@", genre)
                        let subscription = CKQuerySubscription(recordType: "Whistles", predicate: predicate, options: .firesOnRecordCreation)
                        
                        let notification = CKNotificationInfo()
                        notification.alertBody = "There is a new whistle in the \(genre) genre."
                        notification.soundName = "default"
                        
                        subscription.notificationInfo = notification
                        
                        database.save(subscription) { result, error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "Error", message: "There was a problem fetching the subscriptions; please try again", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                
                print(error!.localizedDescription)
            }
        }
        
    }
}
