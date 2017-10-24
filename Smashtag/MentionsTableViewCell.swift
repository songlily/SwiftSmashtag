//
//  MentionsTableViewCell.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-19.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var twitterImageView: UIImageView!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    var tweet: Twitter.Tweet! { didSet { updateUI() } }
    var imageNum: Int?
    var row: Int?
    
    private func updateUI() {
        hashtagLabel?.text = tweet.hashtags[row!].keyword       //individualTag
        usernameLabel?.text = tweet.userMentions[row!].keyword      //individualUser
        urlLabel?.text = tweet.urls[row!].keyword       //individualURL
        
        if tweet.media.count != 0 && imageNum != nil {
            if let twitterImageURL = tweet?.media[imageNum!].url {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let imageData = try? Data(contentsOf: twitterImageURL) {
                        DispatchQueue.main.async {
                            self?.twitterImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            } else {
                twitterImageView?.image = nil
            }
        }
    }

}
