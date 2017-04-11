//
//  ViewController.swift
//  Project37
//
//  Created by D D on 2017-04-10.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import GameplayKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var gradientView: GradientView!
    
    var allCards = [CardViewController]()
    
    var music: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadCards()
        createParticles()
        
        view.backgroundColor = UIColor.red
        
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: { 
            self.view.backgroundColor = UIColor.blue
        })
        
        playMusic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer)
        
        for card in allCards {
            if card.view.frame.contains(location) {
                if view.traitCollection.forceTouchCapability == .available {
                    if touch.force == touch.maximumPossibleForce {
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }
            }
        }
    }
    func loadCards() {
        
        //  First clear any existing cards
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParentViewController()
        }
        
        allCards.removeAll(keepingCapacity: true)
        
        // Array of card positions
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]
        
        //  Load the card images
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        //  Create array of images, one for each of the eight cards
        //  then shuffle
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: images) as! [UIImage]
        
        for (index, position) in positions.enumerated() {
            //  Create a new CardViewController for each card
            let card = CardViewController()
            card.delegate = self
            
            // use view controller containment and card's view to our cardContainer
            addChildViewController(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParentViewController: self)
            
            //  Position the card
            card.view.center = position
            card.front.image = images[index]
            
            //  Mark star image as correct answer
            if card.front.image == star {
                card.isCorrect = true
            }
            
            //  Put the new card view controller in the array for tracking
            allCards.append(card)
        }
    }
    
    func cardTapped(_ tapped: CardViewController) {
        
        //  Prevents issue of two cards being tapped at once
        guard view.isUserInteractionEnabled == true else { return }
        view.isUserInteractionEnabled = false
        
        for card in allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
            } else {
                card.wasntTapped()
            }
        }
        
        perform(#selector(loadCards), with: nil, afterDelay: 2)
        
        view.isUserInteractionEnabled = true
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50)
        particleEmitter.emitterShape = kCAEmitterLayerLine
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = kCAEmitterLayerAdditive
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        
        //  Add as subLayer of gradient view so it always goes behind cards
        gradientView.layer.addSublayer(particleEmitter)
    }
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                //  Repeat music forever
                music.numberOfLoops = -1
                music.play()
            }
        }
    }
}

