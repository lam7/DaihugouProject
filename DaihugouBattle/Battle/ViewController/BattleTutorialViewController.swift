//
//  BattleTutorialViewController.swift
//  DaihugouBattle
//
//  Created by main on 2019/06/16.
//  Copyright © 2019 Main. All rights reserved.
//

import Foundation
import UIKit
import EAIntroView

class BattleTutorialViewController: BattleViewController{
    override func prepareBattlePlayer(_ completion: @escaping () -> ()){
        let tutorialCardIds = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10]
        let ownerDeck = Deck(cards: tutorialCardIds.map{ CardList.get(id: $0)! }.map{ CardBattle(card: $0) })
        let enemyDeck = Deck(cards: tutorialCardIds.map{ CardList.get(id: $0)! }.map{ CardBattle(card: $0) })
        self.battleMaster = LocalBattleMaster(ownerName: "オーナー", ownerId: "0", ownerDeck: ownerDeck, enemyName: "敵", enemyId: "1", enemyDeck: enemyDeck)
        completion()
        return
    }
    
    override func battleReady(){
        //バトル開始
        self.battleMaster.gameStart({_ in})
    }
}
