//
//  API.swift
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
 The API Class connects to the Skylark API to access content and present it type safe structs
 */
class API {
    
    /// Singleton instance
    static let instance = API()
    
    /// Log
    let log = SwiftyBeaver.self
    
    /// The base URL
    let baseURL = "http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk"
    
    /**
     Get sets
     */
    func getSets (completion : @escaping (_ isSuccess : Bool, _ sets : [APISet]?, _ errroMessage : String?) -> Void) {
        
        let apiString = "\(baseURL)/api/sets/"
        log.verbose("Getting sets with URL \(apiString)")
        
        /// Show network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /// Request
        Alamofire.request(apiString).responseJSON { response in
            // Hide network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            /// Check for error
            if let errorReply = APIErrorHelper.instance.checkForError(response) {
                let errroMsg = APIErrorHelper.instance.getErrorMessageFromError(errorReply, forURL: apiString)
                completion(false, nil, errroMsg)
                
                return
            }
            
            self.log.verbose("Response for getting sets \(response.response.debugDescription)")
            
            if let result = response.result.value {
                let json = JSON(result)
                
                if json != JSON.null {
                    if let sets = APISet.parse(json) {
                        
                        completion(true, sets, nil)
                        return
                    }
                }
                
                completion(false, nil, nil)
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    
    /**
     Updates an APISet object from the /sets/ endpoint to a full formed APISet with correct images
     
     - parameter set: The APISet to convert
     - returns: APISet
     */
    func updateSet (set : APISet, completion : @escaping (_ isSuccess : Bool, _ set : APISet?, _ errroMessage : String?) -> Void) {
        
        guard let apiString = set.imageURLs.first else {
            return
        }
        
        log.verbose("Getting image information with URL \(apiString)")
        
        /// Show network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /// Request
        Alamofire.request("\(self.baseURL)\(apiString)").responseJSON { response in
            // Hide network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            /// Check for error
            if let errorReply = APIErrorHelper.instance.checkForError(response) {
                let errroMsg = APIErrorHelper.instance.getErrorMessageFromError(errorReply, forURL: apiString)
                completion(false, nil, errroMsg)
                
                return
            }
            
            self.log.verbose("Response for getting set image \(response.response.debugDescription)")
            
            if let result = response.result.value {
                let json = JSON(result)
                guard let url = json["url"].string else {
                    completion(false, nil, nil)
                    return
                }
                
                let newSet = APISet(uid: set.uid, slug: set.slug, title: set.title, setDescription: set.setDescription, setDescriptionFormatted: set.setDescriptionFormatted, summary: set.summary, imageURLs: [url], items: set.items)
                completion(true, newSet, nil)
                
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    /**
     Get correct image for a Set
     
     - parameter apiString: The API url for the image
     - returns: The correct url of the image
     */
    func getImageForURL (apiString : String, completion : @escaping (_ isSuccess : Bool, _ url : String?, _ errroMessage : String?) -> Void) {
        log.verbose("Getting image information with URL \(apiString)")
        
        /// Show network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /// Request
        Alamofire.request("\(self.baseURL)\(apiString)").responseJSON { response in
            // Hide network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            /// Check for error
            if let errorReply = APIErrorHelper.instance.checkForError(response) {
                let errroMsg = APIErrorHelper.instance.getErrorMessageFromError(errorReply, forURL: apiString)
                completion(false, nil, errroMsg)
                
                return
            }
            
            self.log.verbose("Response for getting set image \(response.response.debugDescription)")
            
            if let result = response.result.value {
                let json = JSON(result)
                guard let url = json["url"].string else {
                    completion(false, nil, nil)
                    return
                }
                
                completion(true, url, nil)
                
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    /**
     Get Episode
     
     - parameter apiString: The API url for the episode
     - parameter divider: The divider the episode belongs to
     - returns: APISet
     */
    func getEpisode (apiString : String, forDivider divider: Divider?, completion : @escaping (_ isSuccess : Bool, _ set : APISet?, _ divider: Divider?, _ errroMessage : String?) -> Void) {
        
        log.verbose("Getting set information with URL \(apiString)")
        
        /// Show network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /// Request
        Alamofire.request("\(self.baseURL)\(apiString)").responseJSON { response in
            // Hide network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            /// Check for error
            if let errorReply = APIErrorHelper.instance.checkForError(response) {
                let errroMsg = APIErrorHelper.instance.getErrorMessageFromError(errorReply, forURL: apiString)
                completion(false, nil, nil, errroMsg)
                
                return
            }
            
            self.log.verbose("Response for getting set image \(response.response.debugDescription)")
            
            if let result = response.result.value {
                let json = JSON(result)
                
                if json != JSON.null {
                    let newSet = APISet.init(json)
                    
                    completion(true, newSet, divider, nil)
                    return
                }
                
                completion(false, nil, nil, nil)
                
            } else {
                completion(false, nil, nil, nil)
            }
        }
    }
}
