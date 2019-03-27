//
//  GiftBox.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

extension Errors{
    class GiftedItem{
        static let notExistId = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "ギフトエラー",
                                                                                  NSLocalizedFailureReasonErrorKey : "指定Idが存在しません"])
    }
}
struct GiftedItem{
    var objectId: String
    var timeStamp: Date
    var timeLimit: Date
    var id: Int{
        didSet{
            
        }
    }
    var subId: Int
    var title: String
    var description: String
    var count: Int
    var imageNamed: String
    private static let GiftedItemEffectInstances: [GiftedItemEffect.Type] = [GiftedItemGold.self, GiftedItemCard.self, GiftedItemCrystal.self]
    private var giftedItemEffect: GiftedItemEffect
    
    init(objectId: String, timeStamp: Date, timeLimit: Date, id: Int, subId: Int, description: String, count: Int, imageNamed: String) throws {
        self.objectId = objectId
        self.timeStamp = timeStamp
        self.timeLimit = timeLimit
        self.id = id
        self.subId = subId
        self.description = description
        self.count = count
        self.imageNamed = imageNamed
        self.giftedItemEffect = try getGiftedItemEffect()
        self.title = giftedItemEffect.name()
    }
    
    private func getGiftedItemEffect() throws -> GiftedItemEffect{
        for instance in GiftedItem.GiftedItemEffectInstances{
            guard let giftedItemEffect = instance.init(giftedItem: self) else{
                continue
            }
            return giftedItemEffect
        }
        throw Errors.GiftedItem.notExistId
    }
    
    func updateEffectInfo(_ effectInfo: inout GiftedItemEffectInfo){
        giftedItemEffect.updateEffectInfo(&effectInfo)
    }
    
    func timeStampFormat()-> String{
        let f       = DateFormatter()
        f.dateStyle = DateFormatter.Style.medium
        f.timeStyle = DateFormatter.Style.short
        f.locale    = Locale(identifier: "ja_JP")
        return f.string(from: timeStamp)
    }
    
    func remainingTime()-> Double{
        let now = Date()
        return timeLimit.timeIntervalSince(now)
    }
    
    func remainingTimeFormat()-> String{
        var remainingTime = self.remainingTime()
        let day           = (remainingTime / (60 * 60 * 24)).i
        remainingTime     -= 60 * 60 * 24 * day.d
        let hour          = (remainingTime / (60 * 60)).i
        remainingTime     -= 60 * 60 * hour.d
        let minute        = (remainingTime / 60).i
        var text = "期限切れ"
        if minute > 0 {
            text = "あと\(minute)分"
        }
        if hour > 0{
            text = "あと\(hour)時間"
        }
        if day > 0 {
            text = "あと\(day)日"
        }
        return text
    }
}

struct GiftedItemEffectInfo{
    var crystal: Int
    var gold: Int
    var ticket: Int
    var cards: [Card]
    
    static func empty()-> GiftedItemEffectInfo{
        return GiftedItemEffectInfo(crystal: 0, gold: 0, ticket: 0, cards: [])
    }
}

class GiftedItemEffect{
    var id: Int{
        return 0
    }
    private(set) var giftedItem: GiftedItem!
    
    required init?(giftedItem: GiftedItem){
        guard id == giftedItem.id else{
            return nil
        }
        self.giftedItem = giftedItem
    }
    
    func name()-> String{
        return ""
    }
    
    func updateEffectInfo(_ effectInfo: inout GiftedItemEffectInfo){
        
    }
}

fileprivate class GiftedItemGold: GiftedItemEffect{
    override var id: Int{
        return 1
    }
    
    override func name() -> String {
        return "\(giftedItem.subId)G"
    }
    
    override func updateEffectInfo(_ effectInfo: inout GiftedItemEffectInfo) {
        effectInfo.gold += giftedItem.subId * giftedItem.count
    }
}

fileprivate class GiftedItemCrystal: GiftedItemEffect{
    override var id: Int{
        return 2
    }
    
    override func name() -> String {
        return "\(giftedItem.subId)C"
    }
    
    override func updateEffectInfo(_ effectInfo: inout GiftedItemEffectInfo) {
        effectInfo.crystal += giftedItem.subId * giftedItem.count
    }
}

fileprivate class GiftedItemCard: GiftedItemEffect{
    override var id: Int{
        return 3
    }
    
    override func name() -> String {
        if let name = CardList.get(id: giftedItem.subId)?.name{
            return name
        }
        return ""
    }
    
    override func updateEffectInfo(_ effectInfo: inout GiftedItemEffectInfo) {
        guard let card = CardList.get(id: giftedItem.subId) else{
            print("Gift card: \(giftedItem.subId) not founded")
            return
        }
        effectInfo.cards += card
    }
}

class Giftbox{
    private(set) var giftedItems =
    func receive(_ giftedItem: GiftedItem){
        var effectInfo = GiftedItemEffectInfo.empty()
        giftedItem.updateEffectInfo(&effectInfo)
        
    }
    
    func receiveAll(_ giftedItems: [GiftedItem]){
        var effectInfo = GiftedItemEffectInfo.empty()
        for giftedItem in giftedItems{
            giftedItem.updateEffectInfo(&effectInfo)
        }
        
    }
    
    
    
    func setup(_ completion: @escaping (Error?)->()){
        UserInfo.shared.getGiftedItemInfos{ error, giftedItems in
            
            completion(error)
        }
    }
}
