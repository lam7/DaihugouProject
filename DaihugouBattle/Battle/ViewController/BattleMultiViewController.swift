//
//  BattleMultiViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/02.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class BattleMultiViewController: BattleViewController{
    var _ownerDeck: Deck!
    private var battleRoom: FirebaseBattleRoom!
    override func prepareBattlePlayer(_ completion: @escaping () -> ()){
        let ownerDeck = Deck(cards: self._ownerDeck.cards.map({ CardBattle(card: $0) }))
        let hp = ownerDeck.cards.reduce(0, { $0 + $1.hp })
        print("\(UserLogin.uuid)   \(hp)")
        battleRoom = FirebaseBattleRoom(maxHP: hp)
        SVProgressHUD.show()
        battleRoom.setUp{error in
            if let error = error{
                SVProgressHUD.showError(withStatus: "エラー")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }
            self.battleRoom.exchangePlayerInfo(){
                maxHP, name, id in
                SVProgressHUD.dismiss()
                self.battleMaster = FirebaseBattleMaster(ownerName: UserInfo.shared.nameValue, ownerId: UserLogin.uuid, ownerDeck: self._ownerDeck, enemyName: name, enemyId: id, enemyMaxHP: maxHP, battleRoom: self.battleRoom)
                completion()
            }
        }
    }
    
    override func battleReady(){
        battleRoom.ready{
            self.battleMaster.gameStart({_ in})
        }
    }
}
