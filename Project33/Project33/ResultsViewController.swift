//
//  ResultsViewController.swift
//  Project33
//
//  Created by D D on 2017-04-07.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import CloudKit
import AVFoundation

class ResultsViewController: UITableViewController {

    var whistle: Whistle!
    var suggestions = [String]()
    
    var whistlePlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Genre: \(whistle.genre!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //  Get ready to retrieve the current suggestions from CloudKit
        let reference = CKReference(recordID: whistle.recordID, action: .deleteSelf)
        let pred = NSPredicate(format: "owningWhistle == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Suggestions", predicate: pred)
        query.sortDescriptors = [sort]
        
        //  Use the convenience API to get the records.
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] (results, error) in
            if let error = error {
                print (error.localizedDescription)
            } else {
                if let results = results {
                    self.parseResults(records: results)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func parseResults(records: [CKRecord]) {
        // Temporary array to store retrieved suggestions
        var newSuggestions = [String]()
        
        //  Load up the array
        for record in records {
            newSuggestions.append(record["text"] as! String)
        }
        
        //  Update the suggestions var and reload the table on the main thread
        DispatchQueue.main.async { [unowned self] in
            self.suggestions = newSuggestions
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //  Header section for the Whistle and a second section for suggestions
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  Only one row needed for the header
        if section == 0 {
            return 1
        } else {
            return suggestions.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Suggested Songs"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //  These rows are not allowed to be selected
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.section == 0 {
            //  user's comments about the whistle
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            
            if whistle.comments.characters.count == 0 {
                cell.textLabel?.text = "Comments: None"
            } else {
                cell.textLabel?.text = whistle.comments
            }
        } else {
            //  The suggestions area
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            
            //  First show all the comments and then the "Add Suggestion" row
            if indexPath.row == suggestions.count {
                //  our extra row
                cell.textLabel?.text = "Add suggestion"
                cell.selectionStyle = .gray
            } else {
                cell.textLabel?.text = suggestions[indexPath.row]
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  If we did not select the last row the leave
        guard indexPath.section == 1 && indexPath.row == suggestions.count else { return }
        
        //  Deselect the tapped row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //  Create an alert box for the user to enter the suggestion
        let ac = UIAlertController(title: "Suggest a song...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        //  When submit is pressed only submit the suggestion if it is not blank
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (acton) in
            if let textField = ac.textFields?[0] {
                if textField.text!.characters.count > 0 {
                    self.add(suggestion: textField.text!)
                }
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    //  Adds the suggestion the CloudKit area
    func add(suggestion: String) {
        let whistleRecord = CKRecord(recordType: "Suggestions")
        let reference = CKReference(recordID: whistle.recordID, action: .deleteSelf)
        whistleRecord["text"] = suggestion as CKRecordValue
        //  Reference to the whistle that the suggestion relates to
        whistleRecord["owningWhistle"] = reference as CKRecordValue
        
        //  Save this into Cloud Kit
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] (record, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestions.append(suggestion)
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    func downloadTapped() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: whistle.recordID) { [unowned self] (record, error) in
            if let error = error {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Error", message: "There was a problem downloading the audio file; please try again.  \(error.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            } else {
                if let record = record {
                    if let asset = record["audio"] as? CKAsset {
                        self.whistle.audio = asset.fileURL
                        
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(self.listenTapped))
                        }
                    }
                }
            }
        }
    }
    
    func listenTapped() {
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: whistle.audio)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback Failed", message: "There was a problem playing your whistle; please try re-recording", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present (ac, animated: true)
        }
    }
}
