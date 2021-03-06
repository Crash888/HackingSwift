//
//  ViewController.swift
//  Project38
//
//  Created by D D on 2017-04-10.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //  Create a property so we can share it throughout the app
    var container: NSPersistentContainer!
    
    //var commits = [Commit]()
    
    var commitPredicate: NSPredicate?
    
    //  Helpful for efficiency and syncing UI to data changes
    var fetchedResultsController: NSFetchedResultsController<Commit>!
    
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
        /*
         When using our own Commit array use this.  Otherwise use the
         fetchedResultsController
        return 1
        */
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         When using our own Commit array use this.  Otherwise use the
         fetchedResultsController
 
        return commits.count
        */
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        /*
            When using our own Commit array use this.  Otherwise use the
            fetchedResultsController
        let commit = commits[indexPath.row]
        */
        
        let commit = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            /*
                When using our own Commit array use this.  Otherwise use the
                fetchedResultsController
 
            vc.detailItem = commits[indexPath.row]
            */
            
            vc.detailItem = fetchedResultsController.object(at: indexPath)
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        /*
            When using our own Commit array use this.  Otherwise use the
            fetchedResultsController.
            This requires rewriting a lot of the code below
 
        //  Deleting a row from our tableview
        if editingStyle == .delete {
            //  Get the Commit
            let commit = commits[indexPath.row]
            // Remove from the managed context
            container.viewContext.delete(commit)
            //  Remove from our array
            commits.remove(at: indexPath.row)
            //  Remove from the TableView
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //  Call save contect so the changes persist
            saveContext()
        }
        */
        
        //  Using fetchedResultsController.  No need to delete from table
        //  or array.  Only the context.  This will result in a call to
        //  controller(didChange:) below which will delete rows from the
        //  table
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
            saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }
    
    //  Called by the fetchedResultsController when an object changes (like our delete).
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let index = indexPath {
                tableView.deleteRows(at: [index], with: .automatic)
            }
            
        default:
            break
        }
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
        let newestCommitDate = getNewestCommitDate()
        
        if let data = try? Data(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since\(newestCommitDate)")!) {
            
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
    
    //  Retrieve the latest commit date that we have.  If we have no items then
    //  just return a date far in the past.
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                //  Add a 1 second time interval so the last commit doesn't get
                //  returned again
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    //  Convert the JSON data into our Commit object
    func configure(_ commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        
        //  Does the author already exist?
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        //  Used try? for teh fetch because it may fail
        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                //  Got the author already
                commitAuthor = authors[0]
            }
        }
        
        //  Didn't find an author
        if commitAuthor == nil {
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        //  Assign author to commit
        commit.author = commitAuthor
        
    }
    
    //  Call the data store to retrive Commit records
    func loadSavedData() {
        
        /*
            Old code.  Works just fine but inefficient.  Causes 100's of
            Commits objects to be initialized.  One for each Commit
         
            New code uses NSFetchedResultsController which helps with this
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
        */
        
        //  The NSFetchedResultsController code
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
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
        
        //  5. Find commits by specified author
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

