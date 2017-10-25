//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-17.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UISplitViewControllerDelegate, UITextFieldDelegate {
    
    // Model
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            print(tweets)
        }
    }
    var recents = UserDefaults.standard.array(forKey: "recentSearches") ?? [String]()
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil                //refresh
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
            
            recents = recents.removeDuplicates(with: searchText)                //removes duplicates case insensitively
            recents.insert(searchText!, at: 0)
            recents = recents.cap(recents, at: 100)                             //caps array at 100 items
            UserDefaults.standard.set(recents, forKey: "recentSearches")       //
        }
    }
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mentionsTVC = (segue.destination.contents as? MentionsTableViewController) {
            // pass tweet image, hashtag, users, url mentions
            let indexPath = tableView.indexPath(for: (sender as! UITableViewCell))
            mentionsTVC.tweet = tweets[indexPath!.section][indexPath!.row]
            
        }
    }
    
    //open master view screen first
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contents == self {
            if (secondaryViewController.contents as? MentionsTableViewController) != nil {
                return true
            }
        }
        return false
    }
    
    // Updating Table
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)        //safe+retweets filter
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in // this is off the main queue
                DispatchQueue.main.async { // so dispatch back to main queue
                    if request == self?.lastTwitterRequest {
                        self?.tweets.insert(newTweets, at:0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    self?.refreshControl?.endRefreshing()   // end refreshing
                }
            }
        } else {
            self.refreshControl?.endRefreshing()            // end refreshing
        }
    }
    
    // Refresh
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // VC Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // Search TextField
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell
        let tweet = tweets[indexPath.section][indexPath.row]
//        cell.textLabel?.text = tweet.text
//        cell.detailTextLabel?.text = tweet.user.name
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }

        return cell
    }
    
    // Adds little numbers in section headers after refreshing
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }

}

extension UIViewController {
    var contents: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController ?? self
        } else {
            return self
        }
    }
}

extension Array {
    func removeDuplicates (with text: String?) -> [String] {
        var initialArray = self as! [String]
        var result = initialArray
        var n = 0
        
        guard (initialArray.count > 0) && (text != nil) else {
            return [String]()
        }
        
        for index in (0..<initialArray.count) {
            let item = initialArray[index]
            if (item.caseInsensitiveCompare(text!) == .orderedSame) {
                result.remove(at: index-n)
                n += 1
            }
        }
        return result
    }
    
    func cap(_ array: Array, at capNumber: Int) -> Array {
        var cappedArray = array
        let itemCount = array.count
        
        if itemCount > capNumber {
            cappedArray = Array(cappedArray.dropLast(itemCount - capNumber))
        }
        return cappedArray
    }
}


