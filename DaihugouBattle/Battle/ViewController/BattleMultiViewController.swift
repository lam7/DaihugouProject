//
//  BattleMultiViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/02.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit


class BattleMultiViewController: BattleViewController{
    override func prepareBattlePlayer(_ completion: @escaping () -> ()){
        print("prepareMulti")
        UserInfo.shared.getAllDeck{
            [weak self] decks, error in
            guard let `self` = self else {
                return
            }
            if let error = error{
                dump(error)
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            var ownerDeck: Deck
            var enemyDeck: Deck
            if decks.isEmpty{
               return
            }else{
                var random = decks.compactMap{$0}.random
                ownerDeck = Deck(cards: random.cards.map({ CardBattle(card: $0) }))
                random = decks.compactMap{$0}.random
                enemyDeck = Deck(cards: random.cards.map({ CardBattle(card: $0) }))
            }
            
//            var ownerDeck: Deck
//            let enemyDeck: Deck = CardList.CardDeck.noData
//            if decks.isEmpty{
//                ownerDeck = CardList.CardDeck.test2
//            }else{
//                ownerDeck = decks.random.copy() as! Deck
//            }
            //この辺の処理は変える必要がある
            self.battleMaster = LocalBattleMaster(ownerName: "オーナー", ownerId: 0, ownerDeck: ownerDeck, enemyName: "敵", enemyId: 1, enemyDeck: enemyDeck)
            completion()
        }
    }
}
