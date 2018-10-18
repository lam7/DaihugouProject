//
//  Skill.swift
//  Daihugou
//
//  Created by Main on 2017/05/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

class Skill{
    var description: String = ""
    fileprivate(set) var activateType: ActivateType = .fanfare
    
    enum ActivateType{
        case fanfare, lastWard, always
        
        var description: String{
            switch self {
            case .fanfare:
                return "ファンファーレ"
            case .lastWard:
                return "ラストワード"
            case .always:
                return ""
            }
        }
    }
    
    init(){
        skillInit()
    }

    
    /// description, activateTypeを初期化する
    fileprivate func skillInit(){
        fatalError("Plase override this method")
    }
    
    
    /// その効果が現在の状況で発動するかどうか返す
    ///
    /// - Parameter player: カード所持プレイヤー
    /// - Returns: 発動するかどうか
    func checkActivate(player: Player)-> Bool{
        fatalError("Plase override this method")
    }
    
    
    /// カードの効果を発動させる
    ///
    /// - Parameter player: カード所持プレイヤー
    func activate(player: Player){
        fatalError("Plase override this method")
    }
    
    
    /// カードの効果が発動するか確かめてから、効果を発動させる
    ///
    /// - Parameter player: カード所持プレイヤー
    final func checkAndActivate(player: Player){
        if checkActivate(player: player){
            activate(player: player)
        }
    }
}

class Skill001: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): 相手に2のダメージを与える"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return true
    }
    
    override func activate(player: Player) {
        player.attack(2)
    }
}

class Skill002: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): 手札の枚数が５枚以上なら相手に10のダメージを与える"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return player.hand.count >= 5
    }
    
    override func activate(player: Player) {
        player.attack(10)
    }
}

class Skill003: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): 3体力を回復する"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return true
    }
    
    override func activate(player: Player) {
        player.heel(3)
    }
}

class Skill004: Skill{
    override func skillInit() {
        self.activateType = .lastWard
        self.description = "\(activateType.description): ５体力を回復する"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return true
    }
    
    override func activate(player: Player) {
        player.heel(5)
    }
}

class Skill005: Skill{
    override func skillInit() {
        self.activateType = .lastWard
        self.description = "\(activateType.description): スポットの枚数が５枚以上なら相手に10のダメージ"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return player.table.spot.allCards.count >= 5
    }
    
    override func activate(player: Player) {
        player.attack(10)
    }
}

class Skill006: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): １枚ドローする"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return true
    }
    
    override func activate(player: Player) {
        player.drawCard()
    }
}

class Skill007: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): 他に手札がない時、スポットの枚数だけドローする"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return player.hand.isEmpty
    }
    
    override func activate(player: Player) {
        player.drawCard(player.table.spot.allCards.count)
    }
}

class Skill008: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): 手札を全て捨て、捨てた枚数×5のダメージ"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return !player.hand.isEmpty
    }
    
    override func activate(player: Player) {
        let count = player.hand.count
        player.removeAllHand()
        player.attack(count * 5)
    }
}

class Skill009: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): インデックス３以下の手札を一枚、ランダムにドローする"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return true
    }
    
    override func activate(player: Player) {
        var cards = player.deck.cards
        cards = cards.filter({ $0.index <= 3 })
        player.drawCard(cards.random)
    }
}

class Skill010: Skill{
    override func skillInit() {
        self.activateType = .fanfare
        self.description = "\(activateType.description): 一番弱い手札を一枚捨て、１枚ドローする"
    }
    
    override func checkActivate(player: Player) -> Bool {
        return true
    }
    
    override func activate(player: Player) {
        var cards = player.hand
        cards.sort(by: { player.table.currentCardStrength.compare($1.index, $0.index )})
        if let card = cards.first{
            player.removeHand([card])
        }
        player.drawCard()
    }
}

class Skill011: Skill{
    override func skillInit() {
        
    }
}
