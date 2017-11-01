//
//  PopularMentionsTableViewController.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-25.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class PopularMentionsTableViewController: FetchedResultsTableViewController {
    
    var mention: String? { didSet{ updateUI() } }
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet{ updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Mention>?
    
    private func updateUI() {
        if let context = container?.viewContext, mention != nil {
            let request: NSFetchRequest<Mention> = Mention.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false),        //sort by count
                                       NSSortDescriptor(key: "keyword",                         // then by name
                                                        ascending: true,
                                                        selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and count > 1", mention!)   //only list count > 1
            
            fetchedResultsController = NSFetchedResultsController<Mention> (
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
        }
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularMentions", for: indexPath)
        if let mention = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = mention.keyword
            cell.detailTextLabel?.text = "in \(mention.count) tweet\(mention.count == 1 ? "" : "s")"
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tweetTVC = segue.destination.contents as? SmashTweetTableViewController {
            let indexPath = tableView.indexPath(for: (sender as! UITableViewCell))
            if let mention = fetchedResultsController?.object(at: indexPath!) {
                tweetTVC.searchText = mention.keyword
            }
        }
    }

}
