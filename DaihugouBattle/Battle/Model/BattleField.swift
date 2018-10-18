//
//  BattleField.swift
//  Daihugou
//
//  Created by Main on 2017/05/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import SceneKit



/// バトル全ての情報を管理するクラス
class BattleField{
    private(set) var owner: Player
    private(set) var enemy: Player
    private(set) var table: Table
    private(set) var spot: Spot
    
    init(owner: Player, enemy: Player){
        self.owner = owner
        self.enemy = enemy
        self.table = Table()
        self.spot  = Spot(table: table)
        //メモリリークをふさぐためこちら側が強参照でインスタンスを持ち
        //Player,Tableが弱参照でBattleFieldを持つ
        owner.battleField = self
        enemy.battleField = self
    }
}

