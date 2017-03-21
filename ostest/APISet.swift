//
//  APISets.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver

/**
 API Sets object
 */
struct APISet {
    
    /// The UID
    let uid : String!

    /// The slug name of the set
    let slug : String!
    
    /// The title of the set
    let title : String!
    
    /// Set description
    let setDescription : String?
    
    /// Set description formatted
    let setDescriptionFormatted : String?
    
    /// Set summary
    let summary : String?
    
    /// Image URLs
    let imageURLs : [String]!
    
    /// The items of the set
    let items : [APIContentItem]!
    
    /**
     A basic initialisers for the API Set object
     
     - parameter uid: The Uid of this set
     - parameter slug: The slug name of this set
     - parameter title: The title of the set
     - parameter setDescription: The description of the set
     - parameter setDescriptionFormatted: The formatter (usually HTML) description of the set
     - parameter summary: A summary of this set
     - parameter imageURLs: An array of image URL Strings for this set
     - parameter imageURLs: An array of content items for this set
     */
    init (uid : String, slug : String, title : String, setDescription : String?, setDescriptionFormatted : String?, summary : String?, imageURLs : [String], items : [APIContentItem]) {
        self.uid = uid
        self.slug = slug
        self.title = title
        self.setDescription = setDescription
        self.setDescriptionFormatted = setDescriptionFormatted
        self.summary = summary
        self.imageURLs = imageURLs
        self.items = items
    }
    
    /**
     Initialises from a JSON object
     
     - parameter json: The JSON object to parse
     */
    init?(_ json : JSON) {
        guard let uid = json["uid"].string else {
            return nil
        }
        
        guard let slug = json["slug"].string else {
            return nil
        }
        
        guard let title = json["title"].string else {
            return nil
        }
        
        guard let imageURLs = json["image_urls"].array else {
            return nil
        }
        
        let setDescription = json["body"].string
        let setDescriptionFormatted = json["formatted_body"].string
        let summary = json["summary"].string
        
        var urls = [String]()
        for thisImageURL in imageURLs {
            if let url = thisImageURL.string {
                urls.append(url)
            }
        }
        
        var contentItems = [APIContentItem]()
        if let items = APIContentItem.parse(json) {
            contentItems = items
        }
        
        self.uid = uid
        self.slug = slug
        self.title = title
        self.setDescription = setDescription
        self.setDescriptionFormatted = setDescriptionFormatted
        self.summary = summary
        self.imageURLs = urls
        self.items = contentItems
    }
    
    
    /**
     Initialises from a JSON object and returns an array of [APISets]
     
     - parameter json: The JSON object to parse
     - returns: [APISets] if the JSON was valid
     */
    static func parse (_ json : JSON) -> [APISet]? {
        
        /// Check there is an array of objects
        guard let objects = json["objects"].array else {
            return nil
        }
        
        /// Sets array
        var apiSets : [APISet] = [APISet]()
        
        /// For each object
        for thisSet in objects {
            
            guard let uid = thisSet["uid"].string else {
                continue
            }
            
            guard let slug = thisSet["slug"].string else {
                continue
            }
            
            guard let title = thisSet["title"].string else {
                continue
            }
            
            guard let setDescription = thisSet["body"].string else {
                continue
            }
            
            guard let setDescriptionFormatted = thisSet["formatted_body"].string else {
                continue
            }
            
            guard let summary = thisSet["summary"].string else {
                continue
            }
            
            guard let imageURLs = thisSet["image_urls"].array else {
                continue
            }
            
            var urls = [String]()
            for thisImageURL in imageURLs {
                if let url = thisImageURL.string {
                    urls.append(url)
                }
            }
            
            var contentItems = [APIContentItem]()
            if let items = APIContentItem.parse(thisSet) {
                contentItems = items
            }
            
            /// Object
            let set = APISet(uid: uid,
                             slug: slug,
                             title: title,
                             setDescription: setDescription,
                             setDescriptionFormatted: setDescriptionFormatted,
                             summary: summary,
                             imageURLs: urls,
                             items: contentItems)
            
            /// Append to array
            apiSets.append(set)
            
        }
        
        /// Return if more than 0
        if apiSets.count > 0 {
            return apiSets
        }
        
        /// Nil return
        return nil
        
    }
    
}

/**
 API Content Item object
 */
struct APIContentItem {
    
    /// The UID
    let uid : String!
    
    /// The heading of the content
    let heading : String!
    
    /// The type of the content
    let contentType : String!
    
    /// The url of the content
    let contentURL : String!
    
    /**
     Initialises from a JSON object and returns an array of [APIContentItem]
     
     - parameter json: The JSON object to parse
     - returns: [APIContentItem] if the JSON was valid
     */
    static func parse (_ json : JSON) -> [APIContentItem]? {
        
        /// Check there is an array of objects
        guard let objects = json["items"].array else {
            return nil
        }
        
        /// Content Items array
        var apiContentItems : [APIContentItem] = [APIContentItem]()
        
        /// For each object
        for thisContentItem in objects {
            /// Content Type & URL are required
            guard let contentType = thisContentItem["content_type"].string, contentType.characters.count > 0 else {
                continue
            }
            
            guard let contentURL = thisContentItem["content_url"].string, contentURL.characters.count > 0 else {
                continue
            }
            
            guard var uid = thisContentItem["uid"].string else {
                continue
            }
   
            /// Set uid from the last part of content type
            if contentType != "divider" {
                uid = NSString(string: contentURL).lastPathComponent
            }
            
            let heading = thisContentItem["heading"].string

            /// Object
            let contentItem = APIContentItem(uid: uid,
                                        heading: heading,
                                        contentType: contentType,
                                        contentURL: contentURL)
            
            /// Append to array
            apiContentItems.append(contentItem)
            
        }
        
        /// Return if more than 0
        if apiContentItems.count > 0 {
            return apiContentItems
        }
        
        /// Nil return
        return nil
        
    }
}
