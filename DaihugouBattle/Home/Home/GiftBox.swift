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
    var objectId: String?
    var timeStamp: Date
    var timeLimit: Date
    var id: Int
    var subId: Int
    var description: String
    var count: Int
    var imageNamed: String
    var title: String
    private static let GiftedItemEffectInstances: [GiftedItemEffect.Type] = [GiftedItemGold.self, GiftedItemCard.self, GiftedItemCrystal.self]
    private var giftedItemEffect: GiftedItemEffect!
    
    init(timeStamp: Date, timeLimit: Date, id: Int, subId: Int, description: String, count: Int, imageNamed: String) throws {
        self.timeStamp = timeStamp
        self.timeLimit = timeLimit
        self.id = id
        self.subId = subId
        self.description = description
        self.count = count
        self.imageNamed = imageNamed
        self.title = ""
        self.giftedItemEffect = try getGiftedItemEffect()
        self.title = giftedItemEffect.name()
    }
    init(objectId: String, timeStamp: Date, timeLimit: Date, id: Int, subId: Int, description: String, count: Int, imageNamed: String) throws {
        self.objectId = objectId
        self.timeStamp = timeStamp
        self.timeLimit = timeLimit
        self.id = id
        self.subId = subId
        self.description = description
        self.count = count
        self.imageNamed = imageNamed
        self.title = ""
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
    
    func receive(_ model: inout UserInfoUpdateServerModel){
        giftedItemEffect.effect(&model)
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
    
    func effect(_ model: inout UserInfoUpdateServerModel){
        
    }
}

fileprivate class GiftedItemGold: GiftedItemEffect{
    override var id: Int{
        return 1
    }
    
    override func name() -> String {
        return "\(giftedItem.subId)G"
    }
    
    override func effect(_ model: inout UserInfoUpdateServerModel){
        model.gain(gold: UInt(giftedItem.subId * giftedItem.count))
    }
}

fileprivate class GiftedItemCrystal: GiftedItemEffect{
    override var id: Int{
        return 2
    }
    
    override func name() -> String {
        return "\(giftedItem.subId)C"
    }
    
    override func effect(_ model: inout UserInfoUpdateServerModel){
        model.gain(crystal: UInt(giftedItem.subId * giftedItem.count))
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
    
    override func effect(_ model: inout UserInfoUpdateServerModel){
        guard let card = CardList.get(id: giftedItem.subId) else{
            print("Gift card: \(giftedItem.subId) not founded")
            return
        }
        let cards = (0..<giftedItem.count).map({_ in card.copy() as! Card })
        model.append(cards: cards)
    }
}

class Giftbox{
    private(set) var giftedItems: [GiftedItem] = []
    private(set) var receivedGiftedItems: [GiftedItem] = []
    
    func receive(_ giftedItem: GiftedItem){
//        giftedItem.updateEffectInfo(&effectInfo)
        
    }
    
    func receiveAll(){
//        var effectInfo = GiftedItemEffectInfo.empty()
//        for giftedItem in giftedItems{
//            giftedItem.updateEffectInfo(&effectInfo)
//        }
        
    }
    
    func setup(_ completion: @escaping ErrorBlock){
        UserInfo.shared.getGiftedItemInfos{ error, giftedItems in
            self.giftedItems = giftedItems
            completion(error)
        }
    }
}
