//
//  SelectGenreTableViewController.swift
//  Project33
//
//  Created by D D on 2017-04-06.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class SelectGenreTableViewController: UITableViewController {

    static var genres = ["Unknown", "Blues", "Classical", "Electronic", "Jazz", "Metal", "Pop", "reggae", "RnB", "Rock", "Soul"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        title = "Select Genre"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Genre", style: .plain, target: nil, action: nil)
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
        
        cell.textLabel?.text = SelectGenreTableViewController.genres[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let genre = cell.textLabel?.text ?? SelectGenreTableViewController.genres[0]
            let vc = AddCommentsViewController()
            vc.genre = genre
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
