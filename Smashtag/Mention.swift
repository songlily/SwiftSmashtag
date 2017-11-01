//
//  Mention.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-27.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class Mention: NSManagedObject {
    class func findOrCreateMention
        (matching inputMention: Twitter.Mention, in context: NSManagedObjectContext) throws -> Mention? {
        
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()                           //request a mention
        request.predicate = NSPredicate(format: "keyword like[c] %@", inputMention.keyword)     //with same keyword
        
        do {
            let matches = try context.fetch(request)                        //try to fetch request
            if matches.count > 0 {                                          //if previously requested
                matches[0].count += 1                                       // then count += 1 to first match
            } else {
                let mention = Mention(context: context)                     //only create new mention if no previous matches
                mention.keyword = "\(inputMention.keyword)"                 //set keyword
                return mention                              //return value if first request
            }
        } catch {
            throw error
        }
        return nil                          //return nil if previously requested
    }
}
