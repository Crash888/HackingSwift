//
//  ViewController.swift
//  Project38
//
//  Created by D D on 2017-04-10.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    //  Create a property so we can share it throughout the app
    var container: NSPersistentContainer!
    
    var commits = [Commit]()
    
    var commitPredicate: NSPredicate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //  Create the persistent containerand provide the Core Data model file
        container = NSPersistentContainer(name: "Project38")
        
        //  Load the saved db, if it exists, otherwise create a new one
        container.loadPersistentStores { (storeDescription, error) in
            
            //  Tells Core Data to update objects.  (ie. if object already exists with the unique
            //  contraint and a message comes in with the same key.  The new memory version 
            //  overwrites teh data store one
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        //  Item to allow user to change the query predicate (or request filter)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
        
        //  Will handle the network requests in the background
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        
        loadSavedData()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = commits[indexPath.row]
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = commit.date.description
        
        return cell
    }
    
    
    //  Call this to write any changes to disk
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error has occurred while saving: \(error)")
            }
        }
    }
    
    //  Network calls to get the data
    func fetchCommits() {
        if let data = try? Data(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!) {
            
            let jsonCommits = JSON(data: data)
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    
                    //  Create a Commit object inside the context.  When we call saveContext()
                    //  changes will get saved into the db
                    let commit = Commit(context: self.container.viewContext)
                    //  Populates the commit object with the json
                    self.configure(commit, usingJSON: jsonCommit)
                }
                
                self.saveContext()
                
                self.loadSavedData()
            }
        }
    }
    
    //  Convert the JSON data into our Commit object
    func configure(_ commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
    }
    
    //  Call the data store to retrive Commit records
    func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = commitPredicate
        
        do {
            commits = try container.viewContext.fetch(request)
            print("Got \(commits.count) commits")
            tableView.reloadData()
        } catch {
            print("Fetch Failed")
        }
    }
    
    func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        
        //  1. Matches objects that have 'fix' in their message  It is case-insensitive
        ac.addAction(UIAlertAction(title: "Show Only Fixes", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })
        
        //  2. Get objects that do not begin 'Merge pull request'
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        })
        
        //  3. Only show commits from up to half a day ago
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        })
        
        //  4.  Show all commits
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { _ in
            self.commitPredicate = nil
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

