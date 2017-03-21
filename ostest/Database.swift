//
//  Database.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyBeaver

/**
 The Database class manages DB access including convenient methods for inserts, deletions and updates
 */
class Database {
    
    /// Static Singleton
    static let instance = Database()
    
    /// Log
    let log = SwiftyBeaver.self
    
    /// Realm DB
    fileprivate var realm = try! Realm()
    
    convenience init(withRealm realm: Realm) {
        self.init()
        self.realm = realm
    }
    
    /**
     Add Episode item into Realm from APISet
     
     - parameter set: The APISets object
     - parameter divider: The divider (if set) the item belongs to
     - parameter lastUpdate: The last update date for the inserted item
     - returns: The Episode object (if created)
     */
    func addEpisodeFromSet(set: APISet, withDivider divider: Divider?, lastUpdate: Date?) -> Episode? {
        log.verbose("Saving Episode with ID: \(set.uid)")
        
        let episode = Episode.initEpisode(withId: set.uid)
        episode <= set
        episode.divider = divider
        
        /// Set update date
        if let lastUpdate = lastUpdate {
            episode.lastUpdate = lastUpdate
        }
        
        do {
            try realm.write {
                realm.add(episode, update: true)
            }
            
            return episode
        }
        catch {
            log.verbose("ERROR on saving Episode with ID: \(episode.uid)")
            return nil
        }
    }
    
    /**
     Fetch Episode matching the given ID
     
     - parameter uid: The requested ID
     - returns: The Episode object (if exists)
     */
    func fetchEpisode(withId uid: String) -> Episode? {
        return realm.object(ofType: Episode.self, forPrimaryKey: uid)
    }
    
    /**
     Returns active (non-deleted) Episodes matching the given divider
     
     - parameter divider: A divider to filter out the episodes (optional)
     - returns: List of episodes
     */
    func fetchActiveEpisodes(forDivider divider: Divider? = nil) -> List<Episode> {
        let data = realm.objects(Episode.self).filter("isDeleted = false")
        
        /// Filter by divider (if set)
        if let divider = divider {
            return List(data.filter({$0.divider == divider}))
        }
        
        return List(data)
    }
    
    /**
     Clear Episodes flagged as deleted
     */
    func clearDeletedEpisodes() {
        let data = realm.objects(Episode.self).filter("isDeleted = true")
        
        log.verbose("Deleting Episodes")
        
        do {
            try realm.write {
                realm.delete(data)
            }
        } catch {
            log.verbose("ERROR on deleting Episodes")
        }
    }
    
    /**
     Flag Episodes as deleted having last update not equal to the parameter
     
     - parameter date: The date to filter out
     */
    func markEpisodesAsDeleted(forLastUpdate date: Date) -> List<Episode> {
        let data = realm.objects(Episode.self).filter("lastUpdate != %@", date)
        
        log.verbose("Preparing Episodes for delete")
        
        let result = List<Episode>()
        for item in data {
            do {
                try realm.write {
                    item.isDeleted = true
                }
                
                result.append(item)
            } catch {
                break
            }
        }
        
        return result
    }
    
    /**
     Update Episode last update date
     
     - parameter object: The episode to be updated
     - parameter imageUrl: The image url
     */
    func updateEpisode(for object: Episode, withLastUpdate date: Date) -> Bool {
        
        log.verbose("Updating Episode last update date with ID: \(object.uid)")
        
        do {
            try realm.write {
                object.lastUpdate = date
            }
            
            return true
        } catch {
            log.verbose("ERROR on updating Episode last update date with ID: \(object.uid)")
            return false
        }
    }
    
    /**
     Update Episode actual image URL
     
     - parameter object: The episode to be updated
     - parameter imageUrl: The image url
     */
    func updateEpisode(for object: Episode, withImageUrl imageUrl: String) -> Bool {
        
        log.verbose("Updating Episode image with ID: \(object.uid)")
        
        do {
            try realm.write {
                if imageUrl.hasPrefix("http") {
                    /// Remove query parameters to improve image caching
                    if let sanitizedUrl = imageUrl.components(separatedBy: "?").first, let url = URL(string: sanitizedUrl) {
                        object.imageURL = url.absoluteString
                    }
                }
            }
            
            return true
        } catch {
            log.verbose("ERROR on updating Episode image with ID: \(object.uid)")
            return false
        }
    }
    
    /**
     (Un)Favorite Episode
     
     - parameter object: The episode
     - parameter isFavorite: The favorite flag
     */
    func updateFavorite(for object: Episode, isFavorite: Bool) {
        log.verbose("Marking Episode as (un)favorite with ID: \(object.uid)")
        
        do {
            try realm.write {
               object.isFavorite = isFavorite
            }
        } catch {
            log.verbose("ERROR ON marking Episode as (un)favorite with ID: \(object.uid)")
        }
    }
    
    /**
     Add Episode item into Realm from APISet
     
     - parameter set: The APISets object
     - parameter divider: The divider (if set) the item belongs to
     - parameter lastUpdate: The last update date for the inserted item
     */
    func addDivider(for contentItem: APIContentItem) -> Divider? {
        let object = Divider.initSetDivider(from: contentItem)
        
        log.verbose("Saving Dividers")
        
        do {
            try realm.write {
                realm.add(object, update: true)
            }
            
            return object
        } catch {
            log.verbose("ERROR on saving Dividers")
            return nil
        }
    }
    
    /**
     Returns Dividers matching the given predicate
     
     - parameter predicate: A predicate format string (optional)
     - parameter completionHandler: (success: Bool, data: Results<Divider>)
     */
    func fetchDividers(predicate: String? = nil) -> List<Divider> {
        var data = realm.objects(Divider.self)
        
        log.verbose("Fetching Dividers from realm")
        
        /// Apply predicate (if set)
        if let predicate = predicate {
            data = data.filter(predicate)
        }
        
        return List(data)
    }
}
