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
    func act()-> [Card]{
        if player.hand.isEmpty{ return [] }
        
        let handCount = player.hand.count
        while true{
            //乱数でパスするかどうか決める
            //この辺は様子を見ながら変更
            if Int.random(in: 0..<200) == 0{ return [] }
            
            //乱数でハンドの組み合わせを決める
            let rand = Int.random(in: 0..<handCount)
            let rand2 = 2 ** rand
            var cards: [Card] = []
            for i in 0..<rand{
                if rand2 & (1 << i) == (1 << i){
                    cards.append(player.hand[i])
                }
            }
            //出せるなら終了
            if player.spot.canPutDown(cards){
                return cards
            }
        }
    }
    
    /// 出せるやつをランダムにだす
    /// - Returns: 出すカード。もし[]なら、なにも出さずに終了
    /// - TODO: 階段を出せるように実装
//    func act()-> [Card]{
//        //手札が空か10％の確率でパス
//        if player.hand.isEmpty{ return []}
//
//        while true{
//
//        }
//        let handCount = player.hand.count
//        switch player.table.spotStatus {
//        case .empty:
//            print("empty")
//            if r == 0{
//                print("single")
//                //シングルでランダムなやつを出す)
//                var t = (0..<hand.count).map{$0}
//                t.shuffle()
//                for _ in 0..<t.count{
//                    let i = t.remove(at: 0)
//                    if spot.canPutDown([hand[i]]){
//                        return [hand[i]]
//                    }
//                }
//                return []
//            }else{
//                print("pair")
//                //ペアでランダムなやつを出す
//                var t = (2...hand.count).map{$0}
//                t.shuffle()
//                for _ in 0..<t.count{
//                    let i = t.remove(at: 0)
//                    var pair = self.pairHand(i)
//                    pair.shuffle()
//                    for _ in 0..<pair.count{
//                        let putDown = pair.remove(at: 0)
//                        if table.checkPutDown(putDown){
//                            return putDown
//                        }
//                    }
//                }
//                return []
//             }
//        case .single:
//            print("singlesss")
//            //シングルでランダムなやつを出す)
//            var t = (0..<hand.count).map{$0}
//            t.shuffle()
//            for _ in 0..<t.count{
//                let i = t.remove(at: 0)
//                if table.checkPutDown([hand[i]]){
//                    return [hand[i]]
//                }
//            }
//            return []
//        case .pair(let count):
//            print("pair\(count)")
//            //ペアでランダムなやつを出す
//            var pair = self.pairHand(count)
//            pair.shuffle()
//            for _ in 0..<pair.count{
//                let putDown = pair.remove(at: 0)
//                if table.checkPutDown(putDown){
//                    return putDown
//                }
//            }
//            return []
//        default:
//            return []
//        }
//    }
    
    private func bitcount16(_ w16: Int)-> Int{
        // 16 bits 限定アルゴリズムを利用している
        var r = ((w16 & 0xAAAA) >> 1) + (w16 & 0x5555)
        r = ((r & 0xCCCC) >> 2) + (r & 0x3333)
        r = ((r & 0xF0F0) >> 4) + (r & 0x0F0F)
        r = ((r & 0xFF00) >> 8) + (r & 0x00FF)
        return r;
    }
}

