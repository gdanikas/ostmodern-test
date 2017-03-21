//
//  ostestUITests.swift
//  ostestUITests
//
//  Created by Maninder Soor on 27/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import XCTest

class ostestUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        /// Stop immediately when a failure occurs.
        continueAfterFailure = false
        
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHasHomeSet() {
        let app = XCUIApplication()
        XCTAssertEqual(app.tables.count, 1)
    }
    
    func testHasEpisodes() {
        let app = XCUIApplication()
        let table = app.tables.element(boundBy: 0)
        
        print(table.cells.count)
        let expectedNumberOfEpisodes: UInt = 20
        XCTAssertEqual(table.cells.count, expectedNumberOfEpisodes)
    }
}
