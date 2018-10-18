//
//  ControllBattleDeck.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/10.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation

protocol ControllBattleCard{
    //自分のターンになったとき、このクラスに通知して手札を引く枚数を計算し、自分にドローしたカード情報を開示する
    //相手がカードを出してきたとき、このクラスに通知して、相手の出してきたカード情報を開示する
    
    init(battleField: BattleField)
}
class ControlBattleDeck{
}
