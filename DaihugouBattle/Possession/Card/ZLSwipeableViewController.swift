//
//  ZLSwipeableViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/09.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift
import Chameleon

class ZLSwipeableViewController: UIViewController {
    @IBOutlet var swipeableView: ZLSwipeableView!
    var currentIndex = 0
    var loadCardsFromXib = false
    var cards: [(card: Card, count: Int)] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
        print(cards)
        self.swipeableView.discardViews()
        self.swipeableView.loadViews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction), vector: \(vector)")
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            print("Did tap at location \(location)")
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }
    }
    
//    // MARK: - Actions
//
//    @IBAction func reloadButtonAction() {
//        let alertController = UIAlertController(title: nil, message: "Load Cards:", preferredStyle: .actionSheet)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            // ...
//        }
//        alertController.addAction(cancelAction)
//
//        let ProgrammaticallyAction = UIAlertAction(title: "Programmatically", style: .default) { (action) in
//            self.loadCardsFromXib = false
//            self.currentIndex = 0
//            self.swipeableView.discardViews()
//            self.swipeableView.loadViews()
//        }
//        alertController.addAction(ProgrammaticallyAction)
//
//        let XibAction = UIAlertAction(title: "From Xib", style: .default) { (action) in
//            self.loadCardsFromXib = true
//            self.currentIndex = 0
//            self.swipeableView.discardViews()
//            self.swipeableView.loadViews()
//        }
//        alertController.addAction(XibAction)
//
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    @IBAction func leftButtonAction() {
//        self.swipeableView.swipeTopView(inDirection: .Left)
//    }
//
//    @IBAction func upButtonAction() {
//        self.swipeableView.swipeTopView(inDirection: .Up)
//    }
//
//    @IBAction func rightButtonAction() {
//        self.swipeableView.swipeTopView(inDirection: .Right)
//    }
//
//    @IBAction func downButtonAction() {
//        self.swipeableView.swipeTopView(inDirection: .Down)
//    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        if currentIndex >= cards.count {
            currentIndex = 0
        }
        if cards.outOfRange(currentIndex){
            return nil
        }
        guard let image = cards[currentIndex].card.image else{
            currentIndex += 1
            return nil
        }
        let cardView = CardView(frame: swipeableView.frame)
        cardView.set(image: image)
        //let gradientColors = Array(ColorsFromImage(image, withFlatScheme: true).map({ $0.cgColor }).reversed())
        cardView.backgroundColor = UIColor(averageColorFrom: image, withAlpha: 0)
        
//        characterStatusView.set(card: cards[currentIndex].card)
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = gradientColors
//        gradientLayer.frame = CGRect(x: 0 , y: 0, width: cardView.frame.width, height: cardView.frame.height)
//        cardView.layer.insertSublayer(gradientLayer, at: 0)
        currentIndex += 1
        return cardView
    }
}


