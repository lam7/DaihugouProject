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
    @IBOutlet weak var collection: SpotCollectionView!
    
    override func viewDidLoad() {
        let firebase = FirebaseBattleRoom(maxHP: 0)
        firebase.setUp({_ in })
//        collection.cardsWithIdentifier = spot.cardsWithIdentifer
//        collection.collectionView.reloadData()
    }
}

