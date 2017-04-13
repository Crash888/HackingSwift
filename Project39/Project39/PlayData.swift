//
//  PlayData.swift
//  Project39
//
//  Created by D D on 2017-04-12.
//  Copyright © 2017 D D. All rights reserved.
//

import Foundation

class PlayData {
    var allWords = [String]()
    
    //  A dictionary....but it is slow.  Change to NSCountedSet
    //var wordCounts = [String: Int]()
    var wordCounts: NSCountedSet!
    
    private(set) var filteredWords = [String]()
    
    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            if let plays = try? String(contentsOfFile: path) {
                allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
                
                //  Remove empty lines from the array
                allWords = allWords.filter{ $0 != "" }
                
                /*  This logic to load the wordCounts dictionar is slow.  Replace with
                    NSCountedSet
                for word in allWords {
                    if wordCounts[word] == nil {
                        wordCounts[word] = 1
                    } else {
                        wordCounts[word]! += 1
                    }
                }
                
                //  Removes the duplicates from allWords
                allWords = Array(wordCounts.keys)
                */
                
                wordCounts = NSCountedSet(array: allWords)
                let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) }
                allWords = sorted as! [String]
                
                applyUserFilter("swift")
            }
        }
    }
    
    //  If input is an Integer then we return the number of words that
    //  occur that many times or higher.  Otherwise we return the frequency
    //  that the input word occurs
    func applyUserFilter(_ input: String) {
        if let userNumber = Int(input) {
            //  a number
            applyFilter { self.wordCounts.count(for: $0) >= userNumber }
        } else {
            // a string value
            applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
        }
    }
    
    func applyFilter(_ filter: (String) -> Bool) {
        filteredWords = allWords.filter(filter)
    }
}
