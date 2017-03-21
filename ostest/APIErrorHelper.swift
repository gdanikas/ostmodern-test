//
//  APIErrorHelper.swift
//  ostest
//
//  Created by George Danikas on 12/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver

class APIErrorHelper {
    
    /// Error Codes
    enum NetworkReplyError: Int {
        case none = 0
        case invalidReply
        case unknown
    }
    
    /// Singleton instance
    static let instance = APIErrorHelper()
    
    /// Log
    let log = SwiftyBeaver.self
    
    /**
     Validates the API response and returns an object of NSError
     
     - parameter dataResponse: All data associated with an API response
     - returns: NSError if the API response contains an error object
     */
    func checkForError(_ dataResponse: DataResponse<Any>) -> NSError? {
        var userInfo = [String: AnyObject]()
        
        /// Check for error encountered while executing or validating the result data response
        if let alamoError = dataResponse.result.error as? NSError {
            userInfo["errorCode"] = alamoError.code as AnyObject?
            userInfo["errorMessage"] = alamoError.localizedDescription as AnyObject?
            
            return NSError(domain: AppDomain, code: alamoError.code, userInfo: userInfo)
        }
        
        if let jsonData = dataResponse.data {
            let jsonResponse = JSON(data: jsonData)
            
            /// Check if response has data
            if jsonResponse != JSON.null {
                let errorReply = APIErrorReply.parse(jsonResponse)
                
                /// Check if response contains an error pbject
                if let responseError = errorReply {
                    var errorCode = NetworkReplyError.invalidReply.rawValue
                    
                    /// Get response (if any) status code
                    if let response = dataResponse.response, response.statusCode != 200 {
                        errorCode = response.statusCode
                    }
                    
                    userInfo["errorMessage"] = responseError.error as AnyObject?
                    userInfo["errorCode"] = errorCode as AnyObject?
                    
                    return NSError(domain: AppDomain, code: errorCode, userInfo: userInfo)
                }
            } else {
                /// Unknown error
                return getErrorForNil()
            }
        } else {
            /// Unknown error
            return getErrorForNil()
        }
        
        return nil
    }
    
    /**
     Creates an Error with unknown error code
     */
    func getErrorForNil() -> NSError {
        let error = NSError(domain: AppDomain, code: NetworkReplyError.unknown.rawValue, userInfo: ["errorMessage": NSLocalizedString("Unknown error", comment: "")])
        return error
    }
    
    
    /**
     Returns the message from an API error
     */
    func getErrorMessageFromError(_ error: NSError, forURL apiURL: String) -> String {
        var errorMessage = NSLocalizedString("Something went wrong\nPlease try again later", comment: "")
        if error.code == -1009 {
            errorMessage = NSLocalizedString("No Internet Connection", comment: "")
        }
        
        if let userInfo = error.userInfo as? [String: NSObject] {
            var logMessage = String()
            if let errorCode = userInfo["errorCode"] as? Int {
                logMessage = "\(errorCode)"
                
                if errorCode == -1009 {
                    errorMessage = NSLocalizedString("No Internet Connection", comment: "")
                } else {
                    errorMessage = NSLocalizedString("Something went wrong\nPlease try again later", comment: "")
                }
            }
        
            if let message = userInfo["errorMessage"] as? String {
                if logMessage.characters.count > 0 {
                    logMessage += " - \(message)"
                }
                else {
                    logMessage = message
                }
            }
            
            self.log.error("API ERROR on \(apiURL): \(logMessage))")
        } else {
            self.log.error("API ERROR on \(apiURL): \(error))")
        }
        
        return errorMessage
    }
    
}
