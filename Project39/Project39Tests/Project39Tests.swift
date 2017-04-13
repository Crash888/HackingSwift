//
//  Project39Tests.swift
//  Project39Tests
//
//  Created by D D on 2017-04-12.
//  Copyright © 2017 D D. All rights reserved.
//

import XCTest
@testable import Project39

class Project39Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //  Test the count of all words loaded
    func testAllWordsLoaded() {
        let playData = PlayData()
        XCTAssertEqual(playData.allWords.count, 18440, "allWords must be 18440")
    }
    
    //  Test specific words to ensure load is correct
    func testWordCountsAreCorrect() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "took"), 76, "took does not appear 76 times")
        XCTAssertEqual(playData.wordCounts.count(for: "forward"), 40, "forward does not appear 40 times")
        XCTAssertEqual(playData.wordCounts.count(for: "cut"), 71, "cut does not appear 71 times")
    }
    
    //  Test how long it takes to instantiate a PlayData object
    func testWordsLoadQuickly() {
        //  Run the logic in here 10 times in a row
        //  In this case we are just creating new PlayData objects
        measure {
            _ = PlayData()
        }
    }
    
    //  Test the applyUserFilter function to ensure correct value is reached
    func testUserFilterWorks() {
        let playData = PlayData()
        
        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495)
        
        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55)
        
        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1)
        
        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56)
        
        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7)
        
        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0)
        
    }
}
