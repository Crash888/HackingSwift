//: Playground - noun: a place where people can play

import UIKit
import GameplayKit

print (arc4random())
print (arc4random())
print (arc4random())
print (arc4random())

//  Widely used but problematic
//  It causes some numbers to generate more than others
//  (aka. modulo bias)
print (arc4random() % 6)

//  The proper way of getting a random range
//  Limitation?...only generates a number from 0 to whatever
//  you specify.  Can't do number between 10 and 20
print(arc4random_uniform(6))

//  To do number within a range that doesn;t begin zero...
//  use this...
func RandomInt(min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}

//  Produce truly random number using GameplayKit.
//  Number between -2,147,483,648 and 2,147,483,647
print(GKRandomSource.sharedRandom().nextInt())

//  Random number between 0 and 5
print(GKRandomSource.sharedRandom().nextInt(upperBound: 6))

//  GameplayKit has 3 methods to generate random numbers
//  GKLinearCongruentialRandomSource - best performance, low randomness
//  GKMersenneTwisterRandomSource - lowest performance, high randomness
//  GKARC4RandomSource - good performance, good randomness

//  Generate ARC4Random between 0 and 19 taht can be saved
let arc4 = GKARC4RandomSource()
arc4.nextInt(upperBound: 20)

//  Mersenne Random
let mersenne = GKMersenneTwisterRandomSource()
mersenne.nextInt(upperBound: 20)

//  Good idea to drop values before using ARC4.  At least 769
//  should be dropped or sequences can be guessed
//  Here is how to drop.
arc4.dropValues(1024)


//  Now look at rolling dice.

//  Roll a six sided die?
let d6 = GKRandomDistribution.d6()
d6.nextInt()

//  Here is a 20-sided die
let d20 = GKRandomDistribution.d20()
d20.nextInt()

//  A 11,539 sided die
let crazy = GKRandomDistribution(lowestValue: 1, highestValue: 11539)
crazy.nextInt()

//  Careful when using lowest and highest with upperBound.  Error can occur
let distribution = GKRandomDistribution(lowestValue: 10, highestValue: 20)
//  Line below will print an error
//print(distribution.nextInt(upperBound: 9))

//  The above randoms use an unspecified algorithm.  If you want a specific
//  algorithm then use the special constructor
let rand = GKMersenneTwisterRandomSource()
let distributionRand = GKRandomDistribution(randomSource: rand, lowestValue: 10, highestValue: 20)
print(distributionRand.nextInt())

//  Handling randomness slightly different.
//  GKShuffledDistribution - gets sequences to repeat less frequently
//  GKGaussianDistribution - results form a bell curve distribution

//  GKShuffledDistribution example.  Notice how each number 1 - 6 is shown
//  only once
let shuffled = GKShuffledDistribution.d6()
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())

//  Shuffling objects in an array
let lotteryBalls = [Int](1...49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)
print(shuffledBalls[0])
print(shuffledBalls[1])
print(shuffledBalls[2])
print(shuffledBalls[3])
print(shuffledBalls[4])
print(shuffledBalls[5])


//  Seeding random sources.  If you say where to start then you can produce
//  the same series of random numbers in the future
let fixedLotteryBalls1 = [Int](1...49)
let fixedShuffledBalls1 = GKMersenneTwisterRandomSource(seed: 1001).arrayByShufflingObjects(in: fixedLotteryBalls1)
print(fixedShuffledBalls1[0])
print(fixedShuffledBalls1[1])
print(fixedShuffledBalls1[2])
print(fixedShuffledBalls1[3])
print(fixedShuffledBalls1[4])
print(fixedShuffledBalls1[5])

//  Using same seed results in same random sequence
let fixedLotteryBalls2 = [Int](1...49)
let fixedShuffledBalls2 = GKMersenneTwisterRandomSource(seed: 1001).arrayByShufflingObjects(in: fixedLotteryBalls2)
print(fixedShuffledBalls2[0])
print(fixedShuffledBalls2[1])
print(fixedShuffledBalls2[2])
print(fixedShuffledBalls2[3])
print(fixedShuffledBalls2[4])
print(fixedShuffledBalls2[5])
