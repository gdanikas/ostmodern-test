//
//  APIErrorReply.swift
//  ostest
//
//  Created by George Danikas on 12/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 API Error Reply object
 */
struct APIErrorReply {
    
    /// The traceback
    let traceback : String!
    
    /// The error messagge
    let error : String!
    
    
    /**
     Initialises from a JSON object and returns an object of APIErrorReply
     
     - parameter json: The JSON object to parse
     - returns: APIErrorReply if the JSON was valid
     */
    static func parse (_ json : JSON) -> APIErrorReply? {
        
        /// Check there is an error object
        if  json["traceback"] == JSON.null && json["error"] == JSON.null {
            return nil
        }
        
        let traceback = json["traceback"].stringValue
        let error = json["error"].stringValue
        
        /// Object
        let errorReply = APIErrorReply(traceback: traceback, error: error)
        
        /// Return the object
        return errorReply
    }
}
