//
//  RealmModel.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import RealmSwift


/**
 The Episode Realm Object
 */
class Episode : Object {
    
    dynamic var uid : String = ""
    
    dynamic var title : String = ""
    
    dynamic var setDescription : String = ""
    
    dynamic var setDescriptionFormatted : String = ""
    
    dynamic var summary : String = ""
    
    dynamic var divider : Divider?
    
    dynamic var lastUpdate : Date?
    
    dynamic var isDeleted : Bool = false
    
    dynamic var isFavorite : Bool = false
    
    dynamic var imageEndpointURL : String = ""
    
    dynamic var imageURL : String = ""
    
    var shouldUpdateImageURL: Bool {
        get {
            return imageEndpointURL.characters.count > 0 && imageURL.characters.count == 0
        }
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }
    
    /**
     Creates a Realm Episode object from the APISet
     */
    static func initEpisode (withId uid : String) -> Episode {
        let episode = Episode()
        episode.uid = uid
        
        return episode
    }
    
}

/**
 Oveloading <= operator for setting a realm Episode object from APISet
 */

func <= (lhs: Episode, rhs: APISet) {
    lhs.title = rhs.title
    lhs.setDescription = rhs.setDescription ?? ""
    lhs.setDescriptionFormatted = rhs.setDescriptionFormatted ?? ""
    lhs.summary = rhs.summary ?? ""
    
    if let imageUrl = rhs.imageURLs.first {
        if imageUrl.hasPrefix("http") {
            /// Remove query parameters to improve image caching
            if let imageUrl = rhs.imageURLs.first, let sanitizedUrl = imageUrl.components(separatedBy: "?").first, let url = URL(string: sanitizedUrl) {
                lhs.imageURL = url.absoluteString
            }
        }
        else {
            lhs.imageEndpointURL = imageUrl
        }
    } else {
        lhs.imageEndpointURL = ""
        lhs.imageURL = ""
    }
}

/**
 The Divider realm object for Episode
 */
class Divider : Object {
    
    dynamic var uid : String = ""
    
    dynamic var title : String = ""
    
    override static func primaryKey() -> String? {
        return "uid"
    }
    
    /**
     Creates a Realm Set Divider object from the API Content Item
     */
    static func initSetDivider (from api : APIContentItem) -> Divider {
        
        let divider = Divider()
        divider.uid = api.uid
        divider.title = api.heading
        
        return divider
    }
}
