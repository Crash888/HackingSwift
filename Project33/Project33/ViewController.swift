//
//  ViewController.swift
//  Project33
//
//  Created by D D on 2017-04-06.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UITableViewController {

    //  Used to track if the current view is dirty and requires a fetch
    //  from CloudKit
    static var isDirty = true
    
    var whistles = [Whistle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "What's that Whistle?"
        
        //  Adds a whistle to the app
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        //  Customize the navigation bar's back button to say "Home" insteed of "What's That Whistle"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        //  Select the Genres to be considered an expert on.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Genres", style: .plain, target: self, action: #selector(selectGenre))
        
        //  Register tableView cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  If anything is currently selected then clear it
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if ViewController.isDirty {
            loadWhistles()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //  CloudKit logic to retrieve Whistles
    func loadWhistles() {
        //  Describes filter we use to show results
        //  The value of 'true' means fetch all records....no filters
        let pred = NSPredicate(value: true)
        //  What field do we want to sort on
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        
        //  Create query based on recordType and predicate
        let query = CKQuery(recordType: "Whistles", predicate: pred)
        //  Add sort descriptors
        query.sortDescriptors = [sort]
        
        //  This 'operation' will do all the fetching for us
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["genre", "comments"]
        operation.resultsLimit = 50
        
        //  This is to hold the records we retrieve
        var newWhistles = [Whistle]()
        
        //  Ok, now get the records
        operation.recordFetchedBlock = { record in
            let whistle = Whistle()
            whistle.recordID = record.recordID
            //  Cast from CKRecordValue to String
            whistle.genre = record["genre"] as! String
            whistle.comments = record["comments"] as! String
            newWhistles.append(whistle)
        }
        
        //  Once the records have been retrieved then do this
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    //  We now have a good set of records
                    ViewController.isDirty = false
                    self.whistles = newWhistles
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Fetch Failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        //  The actual execution line
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline), NSForegroundColorAttributeName: UIColor.purple ]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: titleAttributes)
        
        if subtitle.characters.count > 0 {
            let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
            titleString.append(subtitleString)
        }
        
        return titleString
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText = makeAttributedString(title: whistles[indexPath.row].genre, subtitle: whistles[indexPath.row].comments)
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.whistles.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ResultsViewController()
        vc.whistle = whistles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectGenre() {
        let vc = MyGenresViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

