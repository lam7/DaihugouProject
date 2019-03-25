//
//  GiftBox.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

struct GiftedItemInfo{
    var objectId: String
    var timeStamp: Date
    var timeLimit: Date
    var id: Int
    var subId: Int
    var title: String
    var description: String
    var count: Int
    var imageNamed: String
}

class GiftBox{
}

class GiftedItemEffectInfo{
    var crystal: Int = 0
    var gold: Int = 0
    var ticet: Int = 0
    var cards: [Card] = []
}
protocol GiftedItemEffect: class{
    var id: Int{ get }
    func name(_ giftItemInfo: GiftedItemInfo)-> String
    func effect(_ effectInfo: GiftedItemEffectInfo, giftedItem: GiftedIte)
    func effect(_ giftedItem: GiftedItemInfo, completion: @escaping (_ error: Error?) -> ())
}

fileprivate class GiftedItemGold: GiftedItemEffect{
    var id: Int = 1
    
    func name(_ giftItemInfo: GiftedItemInfo) -> String {
        return "\(giftItemInfo.subId)G"
    }
    
    func effect(_ giftedItems: [GiftedItemInfo], completion: @escaping (_ error: Error?) -> ()){
        let amount = giftedItems.reduce(0, {t, giftedItem in t + giftedItem.subId * giftedItem.count})
        UserInfo.shared.gain(gold: amount, completion: completion)
    }
}

fileprivate class GiftedItemCrystal: GiftedItemEffect{
    var id: Int = 2
    
    func name(_ giftItemInfo: GiftedItemInfo) -> String {
        return "\(giftItemInfo.subId)C"
    }
    func effect(_ giftedItems: [GiftedItemInfo], completion: @escaping (_ error: Error?) -> ()){
        let amount = giftedItems.reduce(0, {t, giftedItem in t + giftedItem.subId * giftedItem.count})
        UserInfo.shared.gain(crystal: amount, completion: completion)
        
    }
}

fileprivate class GiftedItemCard: GiftedItemEffect{
    var id: Int = 3
    
    func name(_ giftItemInfo: GiftedItemInfo) -> String {
        if let name = CardList.get(id: giftItemInfo.subId)?.name{
            return name
        }
        return ""
    }
    func effect(_ giftedItems: [GiftedItemInfo], completion: @escaping (Error?) -> ()) {
        var cards: [Card] = []
        for giftedItem in giftedItems{
            guard let card = CardList.get(id: giftedItem.subId) else{
                completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
                return
            }
            cards += [Card](repeating: card, count: giftedItem.subId)
        }
        UserInfo.shared.append(cards: cards, completion: completion)
    }
}

class GiftedItemList{
    private static var list: [GiftedItemEffect] = [GiftedItemCrystal(), GiftedItemCard(), GiftedItemGold()]
    
    static func effect(_ giftedItems: [GiftedItemInfo], completion: @escaping (Error?) -> ()){
        var items = giftedItems
        while !items.isEmpty{
            let id = items.first!.id
            let filter = items.filter{ $0.id == id }
            items = items.filter{ $0.id != id }
            for l in list{
                if l.id == id{
                    l.effect(filter, completion: completion)
                    break
                }
            }
        }
    }
    
    static func name(_ giftedItem: GiftedItemInfo)-> String{
        for l in list{
            if l.id == giftedItem.id{
                return l.name(giftedItem)
            }
        }
        return ""
    }
}


