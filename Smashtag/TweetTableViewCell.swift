//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-17.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet{ updateUI() } }
    
    private func updateUI() {
        tweetTextLabel?.attributedText = attributedString((tweet?.text)!) //tweet?.text
        tweetUserLabel?.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
    private func attributedString(_ text: String) -> NSMutableAttributedString {
        let hashtagColor = [NSForegroundColorAttributeName:UIColor.blue]
        let usernameColor = [NSForegroundColorAttributeName:UIColor.green]
        let urlColor = [NSForegroundColorAttributeName:UIColor.purple]
        
        let attributedText = NSMutableAttributedString(string: text)
        for num in 0..<tweet!.hashtags.count {
            attributedText.addAttributes(hashtagColor, range: (tweet?.hashtags[num].nsrange)!)
        }
        for num in 0..<tweet!.userMentions.count {
            attributedText.addAttributes(usernameColor, range: (tweet?.userMentions[num].nsrange)!)
        }
        for num in 0..<tweet!.urls.count {
            attributedText.addAttributes(urlColor, range: (tweet?.urls[num].nsrange)!)
        }
        
        return attributedText
    }
}
