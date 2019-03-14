//
//  CPU.swift
//  Daihugou
//
//  Created by Main on 2017/05/23.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

/// ランダムにさすCPU
class RandomCPU{
    private var player: Player

    init(player: Player){
        self.player = player
    }
    /// 出せるやつをランダムにだす
    /// - Returns: 出すカード。もし[]なら、なにも出さずに終了
    /// - TODO: 階段を出せるように実装
//    func act()-> [Card]{
//        if player.hand.isEmpty{ return [] }
//
//        let handCount = player.hand.count
//        while true{
//            //乱数でパスするかどうか決める
//            //この辺は様子を見ながら変更
//            if Int.random(in: 0..<200) == 0{ return [] }
//
//            //乱数でハンドの組み合わせを決める
//            let rand = Int.random(in: 0..<handCount)
//            let rand2 = 2 ** rand
//            var cards: [Card] = []
//            for i in 0..<rand{
//                if rand2 & (1 << i) == (1 << i){
//                    cards.append(player.hand[i])
//                }
//            }
//            //出せるなら終了
//            if player.spot.canPutDown(cards){
//                return cards
//            }
//        }
//    }
    
    
    /// 出せるやつをランダムにだす
    /// - Returns: 出すカード。もし[]なら、なにも出さずに終了
    /// - TODO: 階段を出せるように実装
    func act()-> [Card]{
        // 場のカードが一定数以上の場合、確率でパス
        if (player.spot.allCards.last?.index ?? 0) >= 6 && Int.random(in: 0..<100) < 40{
            return []
        }
        let handCount = player.hand.count
        switch player.table.spotStatus {
        case .empty:
            switch Int.random(in: 0..<100){
            case 0..<45:
                return randomSingle()
            case 45..<75:
                return randomPair(4) ?? randomPair(3) ?? randomPair(2) ?? []
            default:
                return randomStair(5) ?? randomStair(4) ?? randomStair(3) ?? []
            }
        case .single:
            return randomSingle()
        case .pair(let count):
            return randomPair(count) ?? []
        case .stairs(let count):
            return randomStair(count) ?? []
        }
    }
    
    private func randomSingle()-> [Card]{
        //シングルでランダムなやつを出す)
        var hand = player.hand.shuffled()
        for _ in 0..<hand.count{
            let card = hand.removeFirst()
            if player.spot.canPutDown([card]){
                return [card]
            }
        }
        return []
    }
    
    private func randomPair(_ pairCount: Int)-> [Card]?{
        var hand = player.hand.shuffled()
        while !hand.isEmpty{
            let card = hand.removeFirst()
            let pair = hand.filter{ $0 == card }
            if player.spot.canPutDown(pair){
                return pair
            }
            hand = hand.filter{ $0 != card }
        }
        return nil
    }
    
    private func randomStair(_ stairCount: Int)-> [Card]?{
        //乱数でハンドの組み合わせを決める
        let hand = player.hand.shuffled()
        for i in 0 ..< 2 ** hand.count{
            var cards: [Card] = []
            guard bitcount16(i) == stairCount else{
                continue
            }
            for j in 0 ..< i{
                if i & (1 << j) == (1 << j){
                    cards.append(player.hand[j])
                }
            }
            if player.spot.canPutDown(cards){
                return cards
            }
        }
        return nil
    }
    
    private func bitcount16(_ w16: Int)-> Int{
        // 16 bits 限定アルゴリズムを利用している
        var r = ((w16 & 0xAAAA) >> 1) + (w16 & 0x5555)
        r = ((r & 0xCCCC) >> 2) + (r & 0x3333)
        r = ((r & 0xF0F0) >> 4) + (r & 0x0F0F)
        r = ((r & 0xFF00) >> 8) + (r & 0x00FF)
        return r;
    }
}
