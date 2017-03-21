//
//  APITests.swift
//  ostest
//
//  Created by George Danikas on 20/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import Ostmodern

class APITests: XCTestCase {
    
    let timeout = 60.0
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     Test on getting Sets from API
     */
    func testGetSets() {
       let expectation = self.expectation(description: "Request should fetch Sets")
        
        var isResponseSuccess = false
        var responseData: [APISet]?
        var error: String?

        API.instance.getSets { (success, sets, errorMessage) in
            isResponseSuccess = success
            responseData = sets
            error = errorMessage
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Checks after expectations
        XCTAssertTrue(isResponseSuccess)
        XCTAssertNotNil(responseData)
        XCTAssertNil(error)
    }
    
    /**
      Test on updating an APISet object from the /sets/ endpoint to a full formed APISet with correct images
     */
    func testUpdateSet() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "SetWithImages", ofType: "json")
        
        guard let filePath = path else {
            XCTFail("The resource SetWithImages.json could not be found")
            return
        }
        
        /// Reading contents of file
        var str: String?
        do {
            str = try String(contentsOfFile: filePath)
        } catch _ {
            XCTFail("Error on parsing json")
            return
        }
        
        guard let jsonString = str else {
            XCTFail("The resource contains no data or invalid json")
            return
        }
        
        // Serialize json string
        let jsonObject = JSON.init(parseJSON: jsonString)
        let set = APISet.init(jsonObject)
        
        guard let testSet = set else {
            XCTFail("Could not create Set from json")
            return
        }
        
        let expectation = self.expectation(description: "Request should fetch the correct images for a Set")
        
        var isResponseSuccess = false
        var responseData: APISet?
        var error: String?
        
        API.instance.updateSet(set: testSet) { (success, set, errorMessage) in
            isResponseSuccess = success
            responseData = set
            error = errorMessage
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Checks after expectations
        XCTAssertTrue(isResponseSuccess)
        XCTAssertNotNil(responseData)
        XCTAssertNil(error)
    }

    /**
     Test on getting correct image for a URL
     */
    func testGetImageForURL() {
        let expectation = self.expectation(description: "Request should fetch correct image details for a URL")
        
        var isResponseSuccess = false
        var responseData: String?
        var error: String?
        
        let imageAPIURL = "/api/images/imag_fcdf67481d8147e6844d838f4112f999/"
        let expectedImageURL = "https://skylark-qa-fixtures.s3.amazonaws.com/media/images/stills/film/943/promo205597680.jpg"
        
        API.instance.getImageForURL(apiString: imageAPIURL) { (success, url, errorMessage) in
            isResponseSuccess = success
            responseData = url
            error = errorMessage
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        // Checks after expectations
        XCTAssertTrue(isResponseSuccess)
        XCTAssertNotNil(responseData)
        
        
        var imageURL = responseData
        /// Remove query parameters (if contains)
        if let imageUrl = responseData, let sanitizedUrl = imageUrl.components(separatedBy: "?").first {
            imageURL = sanitizedUrl
        }
        
        guard let url = URL(string: imageURL!) else {
            XCTFail("Not valid URL")
            return
        }

        XCTAssertEqual(url.absoluteString, expectedImageURL)
        XCTAssertNil(error)
    }
}
