//
//  Project39UITests.swift
//  Project39UITests
//
//  Created by D D on 2017-04-12.
//  Copyright © 2017 D D. All rights reserved.
//

import XCTest

class Project39UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialStateIsCorrect() {
        //  The .tables references all the tables we have.  However, we only have one
        //  so we are ok.  However, if have more then this would return an array and
        //  we would then have to do more with it
        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially")
    }
    
    func testUserFilteringByString() {
        
        //  All this was written by pressing the record button at the bottom of the Xcode screen
        //  It recorded the actions I took so I can write the test
        let app = XCUIApplication()
        app.navigationBars["Shakespeare"].buttons["Search"].tap()
        
        let filterAlert = app.alerts["Filter..."]
        filterAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element.typeText("test")
        filterAlert.buttons["Filter"].tap()
        
        //  Now I added this myself to test the result of the above
        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching 'test'")
    }
}
