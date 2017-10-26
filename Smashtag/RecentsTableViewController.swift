//
//  RecentsTableViewController.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-22.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit


class RecentsTableViewController: UITableViewController {

    var recents: [String]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recents = UserDefaults.standard.array(forKey: "recentSearches") as! [String]
        tableView.reloadData()
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPath(for: (sender as! UITableViewCell))
        if let tweetTVC = (segue.destination.contents as? SmashTweetTableViewController) {
            tweetTVC.searchText = recents[indexPath!.row]
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath)
        cell.textLabel?.text = recents[indexPath.row]
        return cell
    }

}
