//
//  SetViewModelController.swift
//  ostest
//
//  Created by George Danikas on 13/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

final class SetViewModelController {
    fileprivate var episodesViewModelList = List<Episode>()
    fileprivate var runningTasks = [DataRequest]()

    var selectedDivider: Divider?
    
    /**
     Get Episodes count
     */
    var episodesCount: Int {
        return episodesViewModelList.count
    }
    
    /**
     Get Dividers count
     */
    var dividersCount: Int {
        return Database.instance.fetchDividers().count
    }

    /**
     Returns episode realm object containing in the list for the given index
     
     - parameter index: The index of the episode in the list
     - returns: The found episode
     */
    func viewModel(at index: Int) -> Episode {
        return episodesViewModelList[index]
    }
    
    /**
     Returns the index of the episode in the list
     
     - parameter model: The episode in the list
     - returns: The found index
     */
    func indexForModel(model: Episode) -> Int? {
        if let obj = episodesViewModelList.filter({ $0.uid == model.uid}).first, let idx = episodesViewModelList.index(of: obj) {
            return idx
        }
        
        return nil
    }
    
    func loadHomeSet(_ success: ((_ isLoading: Bool, _ insertions: [IndexPath]?, _ modifications: [IndexPath]?, _ deletions: [IndexPath]?) -> Void)?, _ failure: ((_ errorMessage: String?) -> Void)?) {
        
        /// Fetch non-deleted episodes from realm
        self.episodesViewModelList = Database.instance.fetchActiveEpisodes()
        success?(self.episodesViewModelList.count == 0, nil, nil, nil)
        
        /// Group API requests
        let serviceGroup = DispatchGroup()
        serviceGroup.enter()
        
        var insertedEpisodes = [Episode]()
        var updatedEpisodes = [Episode]()
        var lastUpdate: Date?
        
        /// Fetch Home set from server
        API.instance.getSets { [weak self] (isSuccess, sets, errorMessage) in
            guard let sets = sets else {
                failure?(errorMessage)
                serviceGroup.leave()
                return
            }
            
            /// Find Home set
            guard let homeSet = sets.filter({$0.slug == "home"}).first else {
                failure?(errorMessage)
                serviceGroup.leave()
                return
            }

            lastUpdate = Date()
            var lastDivider: Divider?
            
            for contentItem in homeSet.items {
                if contentItem.contentType == "divider" {
                    /// Create or Update Divider realm object
                    lastDivider = Database.instance.addDivider(for: contentItem)
                }
                else if contentItem.contentType == "episode" {
                    
                    let fetchImagesCompletionHandler: (_ episode: Episode) -> Void = { (episode) in
                        serviceGroup.enter()
                        
                        /// Update episode with correct images
                        API.instance.getImageForURL(apiString: episode.imageEndpointURL, completion: { (isSuccess, url, _) in
                            if let url = url {
                                let result = Database.instance.updateEpisode(for: episode, withImageUrl: url)
                                if result {
                                    if let idx = self?.episodesViewModelList.index(of: episode) {
                                        self?.episodesViewModelList[idx] = episode
                                        
                                        updatedEpisodes.append(episode)
                                    }
                                }
                            }
                            
                            serviceGroup.leave()
                        })
                    }
                    
                    /// Check if episode exists and needs to update its image URL
                    let existingEpisode = Database.instance.fetchEpisode(withId: contentItem.uid)
                    if let episode = existingEpisode {
                        /// Update episode last update date
                        if let lastUpdate = lastUpdate {
                            let _ = Database.instance.updateEpisode(for: episode, withLastUpdate: lastUpdate)
                        }
                        
                        /// Update episode with correct images
                        if  episode.shouldUpdateImageURL {
                            fetchImagesCompletionHandler(episode)
                        }
                    } else {
                        serviceGroup.enter()
                        
                        /// Fetch API data for the new Episode
                        API.instance.getEpisode(apiString: contentItem.contentURL, forDivider: lastDivider, completion: { (isSuccess, set, divider, _) in
                            if let set = set {
                                /// Create Episode realm object
                                let newEpisode = Database.instance.addEpisodeFromSet(set: set, withDivider: divider, lastUpdate: lastUpdate)
                                
                                if let episode = newEpisode {
                                    insertedEpisodes.append(episode)
                                    
                                    /// Update episode with correct images
                                    if  episode.shouldUpdateImageURL {
                                        fetchImagesCompletionHandler(episode)
                                    }
                                }
                            }
                            
                            serviceGroup.leave()
                        })
                    }
                }
            }
            
            serviceGroup.leave()
        }
        
        /// Do the rest when all API requests are finished
        serviceGroup.notify(queue: DispatchQueue.main) {
            /// Check if there is Set content
            guard let lastUpdate = lastUpdate else {
                return
            }
            
            var insertedIndexPaths = [IndexPath]()
            var updatedIndexPaths = [IndexPath]()
            var deletedIndexPaths = [IndexPath]()
            
            /// Find Updated episodes
            for episode in updatedEpisodes {
                if let obj = self.episodesViewModelList.filter({ $0.uid == episode.uid}).first, let idx = self.episodesViewModelList.index(of: obj) {
                    updatedIndexPaths.append(IndexPath(row: idx, section: 0))
                    self.episodesViewModelList[idx] = episode
                }
            }
            
            /// Find episodes not included in the API response and mark them as deleted
            let deletedEpisodes = Database.instance.markEpisodesAsDeleted(forLastUpdate: lastUpdate)
            
            /// Find Deleted episodes
            for episode in deletedEpisodes {
                if let obj = self.episodesViewModelList.filter({ $0.uid == episode.uid}).first, let idx = self.episodesViewModelList.index(of: obj) {
                    deletedIndexPaths.append(IndexPath(row: idx, section: 0))
                }
            }
            
            /// Remove Deleted episodes from the viewModel list
            self.episodesViewModelList = List(self.episodesViewModelList.filter { episode in
                return !deletedEpisodes.flatMap{ $0.uid }.contains(episode.uid)
            })
            
            /// Find Inserted episodes
            for episode in insertedEpisodes {
                self.episodesViewModelList.append(episode)
                if let idx = self.episodesViewModelList.index(of: episode) {
                    insertedIndexPaths.append(IndexPath(row: idx, section: 0))
                }
            }
            
            success?(false, insertedIndexPaths, updatedIndexPaths, deletedIndexPaths)
        }
    }
    
    func addToFavorite(for model: Episode, isFavorite: Bool) {
        Database.instance.updateFavorite(for: model, isFavorite: isFavorite)
    }
    
    func setDivider(divider: Divider?) {
        selectedDivider = divider
        
        /// Fetch non-deleted episodes from realm for selected divider (if set)
        self.episodesViewModelList = Database.instance.fetchActiveEpisodes(forDivider: divider)
    }
}
