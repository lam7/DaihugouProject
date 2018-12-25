//
//  ATestViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/02.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification.Name {
    static let InjectBundleNotification = NSNotification.Name("INJECTION_BUNDLE_NOTIFICATION")
}

class TestViewController: UIViewController{
    var table: Table!
    var spot: Spot!
    @IBOutlet weak var collection: SpotCollectionView!
    
    override func viewDidLoad() {
        let s = BattleServerDecoder()
        s.setUp()
        
        table = Table()
        spot = Spot(table: table)
        
        let a = (1...3).map{ _ in CardList.get(id: 1)! }
        let b = (1...3).map{ _ in CardList.get(id: 2)! }
        let c = (1...3).map{ _ in CardList.get(id: 3)! }
        let d = (1...3).map{ _ in CardList.get(id: 4)! }
        spot.putDown(a, isOwner: true)
        spot.putDown(b, isOwner: false)
        spot.putDown(c, isOwner: true)
        spot.putDown(d, isOwner: false)
//        collection.cardsWithIdentifier = spot.cardsWithIdentifer
//        collection.collectionView.reloadData()
    }
}

