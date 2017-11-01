//
//  Tweet.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-25.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class Tweet: NSManagedObject {
    class func findOrCreateTweet
        (matching twitterInfo: Twitter.Tweet, in context: NSManagedObjectContext) throws -> Tweet {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.identifier)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Tweet.findOrCreateTweet -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let tweet = Tweet(context: context)
        tweet.unique = twitterInfo.identifier
        tweet.text = twitterInfo.text
        tweet.created = twitterInfo.created as NSDate
        tweet.tweeter = try? TwitterUser.findOrCreateTwitterUser(matching: twitterInfo.user, in: context)

        if twitterInfo.hashtags.count != 0 {
            for item in twitterInfo.hashtags {
                let mention = try Mention.findOrCreateMention(matching: item, in: context)
                for men in tweet.mentions! {
                    if (men as! Mention).keyword!.lowercased() == mention?.keyword?.lowercased() {
                        tweet.removeFromMentions((men as! Mention))
                    }
                }
                if mention != nil {
                    tweet.addToMentions(mention!)
                }
            }
        }
        if twitterInfo.userMentions.count != 0 {
            for item in twitterInfo.userMentions {
                let mention = try Mention.findOrCreateMention(matching: item, in: context)
                for men in tweet.mentions! {
                    if (men as! Mention).keyword!.lowercased() == mention?.keyword?.lowercased() {
                        tweet.removeFromMentions((men as! Mention))
                    }
                }
                if mention != nil {
                    tweet.addToMentions(mention!)
                }
            }
        }
        
        return tweet
    }
}
