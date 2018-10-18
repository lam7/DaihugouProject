//
//  PrivateBattleMaster.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/10.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation


protocol BattleMaster{
    func initBattleField(_ battleField: BattleField)
    
    
}
///相手味方ともに手札情報を管理する
///本来ならサーバーサイドに書く処理
class PrivateBattleMaster{
    
    init(owner: Player, enemy: Player){
    }
}
