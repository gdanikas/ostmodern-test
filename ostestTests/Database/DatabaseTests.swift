//
//  DatabaseTests.swift
//  ostest
//
//  Created by George Danikas on 20/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift
@testable import Ostmodern

class DatabaseTests: XCTestCase {
    
    var database = Database()
    var bundledSets = [JSON]()
    var bundledDividers: JSON?
    
    override func setUp() {
        super.setUp()
        
        /// Create an in-memory database to avoid polluting the production one
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        /// Initialize realm
        let realm = try! Realm()
        database = Database(withRealm: realm)
        
        /// Load bundled Sets
        if let jsonObject = jsonFromResource(resource: "Sets") {
            bundledSets = jsonObject.arrayValue
        }
        
        /// Load bundled Dividers
        if let jsonObject = jsonFromResource(resource: "Dividers") {
            bundledDividers = jsonObject
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     Returns json object from resouce file
     */
    func jsonFromResource(resource: String) -> JSON? {
        /// Get bundle
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: resource, ofType: "json")
        
        guard let filePath = path else {
            XCTFail("The resource could not be found")
            return nil
        }
        
        /// Reading contents of file
        var str: String?
        do {
            str = try String(contentsOfFile: filePath)
        } catch _ {
            XCTFail("Error on parsing json")
            return nil
        }
        
        guard let jsonString = str else {
            XCTFail("The resource contains no data or invalid json")
            return nil
        }
        
        // Serialize json string
        return JSON.init(parseJSON: jsonString)
    }
    
    
    // MARK: - Episode Tests
    
    /**
     Add Episodes into Realm from bundle
     */
    func testAddEpisodesFromSets() {
        if  bundledSets.count == 0 {
            XCTFail("Bundled Sets not loaded")
            return
        }
        
        var episodes = [Episode]()
        for setJson in bundledSets {
            let newSet = APISet.init(setJson)
            guard let set = newSet else {
                XCTFail("Could not create Set from json")
                return
            }
            
            let newEpisode = database.addEpisodeFromSet(set: set, withDivider: nil, lastUpdate: nil)
            guard let episode = newEpisode else {
                XCTFail("Could not create Episode from Set")
                return
            }
            
            episodes.append(episode)
        }
        
        XCTAssertEqual(episodes.count, 4, "The list should contain 4 Episodes")
    }
    
    /**
     Get Episode for a given uid
     */
    func testFetchEpisode() {
        if  bundledSets.count == 0 {
            XCTFail("Bundled Sets not loaded")
            return
        }
        
        for setJson in bundledSets {
            let newSet = APISet.init(setJson)
            guard let set = newSet else {
                XCTFail("Could not create Set from json")
                return
            }
            
            let episode = database.addEpisodeFromSet(set: set, withDivider: nil, lastUpdate: nil)
            guard let _ = episode else {
                XCTFail("Could not create Episode from Set")
                return
            }
        }
        
        let requestedId = "film_a5e1022dfd874e169fd6da6597d0cd0f"
        let episode = database.fetchEpisode(withId: requestedId)
        guard let _ = episode else {
            XCTFail("Could not fetch Episode with ID \(requestedId)")
            return
        }
        
        XCTAssertEqual(episode?.uid, requestedId, "The ID should be the \(requestedId)")
    }
    
    /**
     Get active Episodes
     */
    func testFetchActiveEpisodes() {
        if  bundledSets.count == 0 {
            XCTFail("Bundled Sets not loaded")
            return
        }
        
        for setJson in bundledSets {
            let newSet = APISet.init(setJson)
            guard let set = newSet else {
                XCTFail("Could not create Set from json")
                return
            }
            
            let episode = database.addEpisodeFromSet(set: set, withDivider: nil, lastUpdate: nil)
            guard let _ = episode else {
                XCTFail("Could not create Episode from Set")
                return
            }
        }
        
        let episodes = database.fetchActiveEpisodes()
        
        XCTAssertEqual(episodes.count, 4, "The active episodes should be 4")
        XCTAssertEqual(episodes[0].uid, "film_a5e1022dfd874e169fd6da6597d0cd0f")
        XCTAssertEqual(episodes[1].uid, "film_f0bc40dc033542afb1cc2413830b7958")
        XCTAssertEqual(episodes[2].uid, "film_89a3da9518674307aaa952f6364945a6")
        XCTAssertEqual(episodes[3].uid, "film_220067fe34f84bd681b3e8b1bcc2979e")
    }
    
    /**
     Delete Episodes
     */
    func testDeleteEpisodes() {
        if  bundledSets.count == 0 {
            XCTFail("Bundled Sets not loaded")
            return
        }
        
        let lastUpdate = Date()
        
        for (index, setJson) in bundledSets.enumerated() {
            let newSet = APISet.init(setJson)
            guard let set = newSet else {
                XCTFail("Could not create Set from json")
                return
            }
            let newEpisode = database.addEpisodeFromSet(set: set, withDivider: nil, lastUpdate: lastUpdate)
            guard let episode = newEpisode else {
                XCTFail("Could not create Episode from Set")
                return
            }
            
            if index > 1 {
                let result = database.updateEpisode(for: episode, withLastUpdate: Date())
                XCTAssertNotEqual(result, false, "Could not update last update date for Episode with ID \(episode.uid)")
            }
        }
        
        let episodesToDelete = database.markEpisodesAsDeleted(forLastUpdate: lastUpdate)
        XCTAssertEqual(episodesToDelete.count, 2, "The Episodes should be deleted are 2")
        
        /// Clear episodes flagged as deleted
        database.clearDeletedEpisodes()
        
        /// Fetch active episodes
        let episodes = database.fetchActiveEpisodes()
        XCTAssertEqual(episodes.count, 2, "The active Episodes should be 2")
    }
    
    /**
     Update Episode image URL
     */
    func testUpdateEpisodeImageURL() {
        if  bundledSets.count == 0 {
            XCTFail("Bundled Sets not loaded")
            return
        }
        
        for setJson in bundledSets {
            let newSet = APISet.init(setJson)
            guard let set = newSet else {
                XCTFail("Could not create Set from json")
                return
            }
            
            let episode = database.addEpisodeFromSet(set: set, withDivider: nil, lastUpdate: nil)
            guard let _ = episode else {
                XCTFail("Could not create Episode from Set")
                return
            }
        }
        
        let episodes = database.fetchActiveEpisodes()
        let imageURL = "https://skylark-qa-fixtures.s3.amazonaws.com/media/images/stills/film/943/promo205597680.jpg"
        
        /// Set image URL for first object of the list
        let result = database.updateEpisode(for: episodes[0], withImageUrl: imageURL)
        XCTAssertNotEqual(result, false, "Could not update image URL for Episode with ID \(episodes[0].uid)")
        
        /// Get episode
        let episode = database.fetchEpisode(withId: "film_a5e1022dfd874e169fd6da6597d0cd0f")
        XCTAssertEqual(episode?.imageURL, imageURL, "The Episode should containt image URL")
    }
    
    /**
     (Un)Favorite Episode
     */
    func testFavoriteEpisode() {
        if  bundledSets.count == 0 {
            XCTFail("Bundled Sets not loaded")
            return
        }
        
        for setJson in bundledSets {
            let newSet = APISet.init(setJson)
            guard let set = newSet else {
                XCTFail("Could not create Set from json")
                return
            }
            
            let episode = database.addEpisodeFromSet(set: set, withDivider: nil, lastUpdate: nil)
            guard let _ = episode else {
                XCTFail("Could not create Episode from Set")
                return
            }
        }
        
        let episodes = database.fetchActiveEpisodes()

        /// Favorite first object of the list
        database.updateFavorite(for: episodes[0], isFavorite: true)
        
        /// Get favorite episode
        let episode = database.fetchEpisode(withId: "film_a5e1022dfd874e169fd6da6597d0cd0f")
        XCTAssertEqual(episode?.isFavorite, true, "The Episode should be marked as favorite")
    }
    
    
    // MARK: - Divider Tests
    
    /**
     Add Dividers into Realm from bundle
     */
    func testAddDividers() {
        guard let jsonDividers = bundledDividers else {
            XCTFail("Bundled Dividers not loaded")
            return
        }
        
        let items = APIContentItem.parse(jsonDividers)
        guard let contentItems = items else {
            XCTFail("Could not create Divider Content Items from json")
            return
        }
        
        var dividers = [Divider]()
        for contentItem in contentItems {
            let newDivider = database.addDivider(for: contentItem)
            guard let divider = newDivider else {
                XCTFail("Could not create Divider from Content Item")
                return
            }
            
            dividers.append(divider)
        }
        
        XCTAssertEqual(dividers.count, 2, "The list should contain 2 Dividers")
    }
    
    /**
     Get Dividers
     */
    func testFetchDividers() {
        guard let jsonDividers = bundledDividers else {
            XCTFail("Bundled Dividers not loaded")
            return
        }
        
        let items = APIContentItem.parse(jsonDividers)
        guard let contentItems = items else {
            XCTFail("Could not create Divider Content Items from json")
            return
        }
        
        for contentItem in contentItems {
            let divider = database.addDivider(for: contentItem)
            guard let _ = divider else {
                XCTFail("Could not create Divider from Content Item")
                return
            }
        }
        
        let dividers = database.fetchDividers()
        
        XCTAssertEqual(dividers.count, 2, "The Dividers should be 2")
        XCTAssertEqual(dividers[0].uid, "sche_7b4c7b54ecfb4748b7853aa5f87ac309")
        XCTAssertEqual(dividers[1].uid, "sche_da321b4852dd4527adc496296819f555")
    }
}
