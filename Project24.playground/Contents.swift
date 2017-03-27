//: Playground - noun: a place where people can play

import UIKit

extension Int {
    mutating func plusOne() {
        return self += 1
    }
}

//  Integer applies to Int, Int8, UInt64, etc.
//  The 'Self' return means return the type of Integer
//  that was passed in.
//  So, 'self' means value of
//  and 'Self' means data type of
extension Integer {
    func squared() -> Self {
        return self * self
    }
}

var str = "Hello, playground"
var myInt = 0
myInt.plusOne()
//5.plusOne()

var myInt2 = 10
myInt2.plusOne()
myInt2

let i: Int = 8
print(i.squared())

let j: UInt64 = 8
print(j.squared())

