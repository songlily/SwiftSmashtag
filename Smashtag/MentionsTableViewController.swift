//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-18.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class MentionsTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet!
    
//    private enum Mentions {
//        case media (title: String, identifier: String)  //, count: Int, url: URL, aspectRatio: Double)
//        case mention (title: String, identifier: String)
//    }
//    
//    private let mentions: [Int:Mentions] = [
//        0: Mentions.media(title: "Images", identifier: "imageCell"),
//        1: Mentions.mention(title: "Hashtags", identifier: "hashtagCell"),
//        2: Mentions.mention(title: "Usernames", identifier: "usernameCell"),
//        3: Mentions.mention(title: "URLs", identifier: "urlCell"),
//    ]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        let indexPath = tableView.indexPath(for: (sender as! UITableViewCell))
        
        if identifier == "imageCell" {
            if let imageVC = (segue.destination.contents as? ImageViewController) {
                imageVC.imageURL = tweet.media[indexPath!.row].url
                imageVC.aspectRatio = tweet.media[indexPath!.row].aspectRatio
            }
        } else if identifier == "mentionCell" {
            if let tweetTVC = (segue.destination.contents as? TweetTableViewController) {
                if indexPath?.section == 1 {
                    tweetTVC.searchText = tweet.hashtags[(indexPath?.row)!].keyword
                } else {
                    tweetTVC.searchText = tweet.userMentions[(indexPath?.row)!].keyword
                }
            }
        } else if identifier == "urlCell" {
            guard let url = URL(string: tweet.urls[indexPath!.row].keyword) else {
                return
            }
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tweet.media.count
        case 1:
            return tweet.hashtags.count
        case 2:
            return tweet.userMentions.count
        case 3:
            return tweet.urls.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && tweet.media.count != 0 {
            let ratio = CGFloat(1/(tweet.media[indexPath.row].aspectRatio))
            return (ratio * tableView.contentSize.width)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return (tweet.media.count != 0) ? "Images" : nil                //"Images"
        case 1:
            return (tweet.hashtags.count != 0) ? "Hashtags" : nil
        case 2:
            return (tweet.userMentions.count != 0) ? "Usernames" : nil
        case 3:
            return (tweet.urls.count != 0) ? "URLs" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            if let mentionCell = cell as? MentionsTableViewCell {
                mentionCell.imageNum = indexPath.row
                mentionCell.tweet = tweet
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "hashtagCell", for: indexPath)
            if let mentionCell = cell as? MentionsTableViewCell {
                mentionCell.row = indexPath.row
                mentionCell.tweet = tweet
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "usernameCell", for: indexPath)
            if let mentionCell = cell as? MentionsTableViewCell {
                mentionCell.row = indexPath.row
                mentionCell.tweet = tweet
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "urlCell", for: indexPath)
            if let mentionCell = cell as? MentionsTableViewCell {
                mentionCell.row = indexPath.row
                mentionCell.tweet = tweet
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

}
