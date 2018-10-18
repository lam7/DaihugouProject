//
//  GiftBox.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import NCMB

struct GiftItemInfo{
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
    static func receivedItems(_ completion: @escaping (_ error: Error?, _ giftedItemsInfo: [(String, GiftItemInfo)]) -> ()){
        guard let object = NCMBObject(className: "userInfo"),
            let query = NCMBQuery(className: "giftedItem") else{
            completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil), [])
            return
        }
        var giftedItems: [(String, GiftItemInfo)] = []
        
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground{ error in
            if let error = error{
                completion(error, [])
            }
            var giftedItemIds = object.object(forKey: "giftedItemObjectIds") as! [String]
            giftedItemIds = giftedItemIds.map({ return deleteDoubleQuotesFirstAndLast($0) })
            query.whereKey("objectIdUserInfo", equalTo: UserLogin.objectIdUserInfo)
            
            query.findObjectsInBackground{ objects,error in
                if let error = error{
                    completion(error, [])
                }
                guard let objects = objects else{
                    completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil), [])
                    return
                }
                for object in objects{
                    guard let obj = object as? NCMBObject,
                        let timeStamp = obj.object(forKey: "timeStamp") as? Date,
                        let timeLimit = obj.object(forKey: "timeLimit") as? Date,
                        let id = obj.intValue(forKey: "id"),
                        let subId = obj.intValue(forKey: "subId"),
                        let title = obj.object(forKey: "title") as? String,
                        let description = obj.object(forKey: "description") as? String,
                        let count = obj.intValue(forKey: "count"),
                        let imageNamed = obj.object(forKey: "imageNamed") as? String,
                        let isReceived = obj.object(forKey: "isReceived") as? Bool,
                        let objectId = obj.objectId else{
                            fatalError("object Error")
                    }
                    
                    if timeLimit.compare(Date()) == ComparisonResult.orderedAscending || isReceived{
                        continue
                    }
                    let giftedItem = GiftItemInfo(timeStamp: timeStamp, timeLimit: timeLimit, id: id, subId: subId, title: title, description: description, count: count, imageNamed: imageNamed)
                    giftedItems.append((objectId, giftedItem))
                }
                completion(nil, giftedItems)
            }
        }
    }
    
    static func historyItems(_ completion: @escaping (_ error: Error?, _ giftedItemsInfo: [(String, GiftItemInfo)]) -> ()){
        guard let object = NCMBObject(className: "userInfo"),
            let query = NCMBQuery(className: "giftedItem") else{
                completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil), [])
                return
        }
        var giftedItems: [(String, GiftItemInfo)] = []
        
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground{ error in
            if let error = error{
                completion(error, [])
            }
            var giftedItemIds = object.object(forKey: "giftedItemObjectIds") as! [String]
            giftedItemIds = giftedItemIds.map({ return deleteDoubleQuotesFirstAndLast($0) })
            query.whereKey("objectIdUserInfo", equalTo: UserLogin.objectIdUserInfo)
            
            query.findObjectsInBackground{ objects,error in
                if let error = error{
                    completion(error, [])
                }
                guard let objects = objects else{
                    completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil), [])
                    return
                }
                for object in objects{
                    guard let obj = object as? NCMBObject,
                        let timeStamp = obj.object(forKey: "timeStamp") as? Date,
                        let timeLimit = obj.object(forKey: "timeLimit") as? Date,
                        let id = obj.intValue(forKey: "id"),
                        let subId = obj.intValue(forKey: "subId"),
                        let title = obj.object(forKey: "title") as? String,
                        let description = obj.object(forKey: "description") as? String,
                        let count = obj.intValue(forKey: "count"),
                        let imageNamed = obj.object(forKey: "imageNamed") as? String,
                        let isReceived = obj.object(forKey: "isReceived") as? Bool,
                        let objectId = obj.objectId else{
                            fatalError("object Error")
                    }
                    
                    if isReceived{
                        let giftedItem = GiftItemInfo(timeStamp: timeStamp, timeLimit: timeLimit, id: id, subId: subId, title: title, description: description, count: count, imageNamed: imageNamed)
                        giftedItems.append((objectId, giftedItem))
                    }
                }
                completion(nil, giftedItems)
            }
        }
    }
}

protocol GiftedItemEffect: class{
    var id: Int{ get }
    func name(_ giftItemInfo: GiftItemInfo)-> String
    func effect(_ giftedItem: GiftItemInfo, completion: @escaping (_ error: Error?) -> ())
}


class GiftedItemGold: GiftedItemEffect{
    var id: Int = 1
    func name(_ giftItemInfo: GiftItemInfo) -> String {
        return "\(giftItemInfo.subId)G"
    }
    func effect(_ giftedItem: GiftItemInfo, completion: @escaping (_ error: Error?) -> ()){
        let amount = giftedItem.subId * giftedItem.count
        UserInfo.shared.gain(gold: amount, completion: completion)
        
    }
}

class GiftedItemCrystal: GiftedItemEffect{
    var id: Int = 2
    
    func name(_ giftItemInfo: GiftItemInfo) -> String {
        return "\(giftItemInfo.subId)C"
    }
    func effect(_ giftedItem: GiftItemInfo, completion: @escaping (_ error: Error?) -> ()){
        let amount = giftedItem.subId * giftedItem.count
        UserInfo.shared.gain(crystal: amount, completion: completion)
        
    }
}

class GiftedItemCard: GiftedItemEffect{
    var id: Int = 3
    
    func name(_ giftItemInfo: GiftItemInfo) -> String {
        if let name = CardList.get(id: giftItemInfo.subId)?.name{
            return name
        }
        return ""
    }
    func effect(_ giftedItem: GiftItemInfo, completion: @escaping (Error?) -> ()) {
        let cardId = giftedItem.subId
        guard let card = CardList.get(id: cardId) else{
            completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
            return
        }
        let cards = [Card](repeating: card, count: giftedItem.count)
        UserInfo.shared.append(cards: cards, completion: completion)
    }
}

class GiftedItemList{
    private static var list: [GiftedItemEffect] = [GiftedItemCrystal(), GiftedItemCard(), GiftedItemGold()]
    static func effect(_ giftedItem: GiftItemInfo, completion: @escaping (Error?) -> ()){
        for l in list{
            if l.id == giftedItem.id{
                l.effect(giftedItem, completion: completion)
                return
            }
        }
        completion(NSError(domain: "com.Daihugou", code: 0, userInfo: nil))
    }
    
    static func name(_ giftedItem: GiftItemInfo)-> String{
        for l in list{
            if l.id == giftedItem.id{
                return l.name(giftedItem)
            }
        }
        return ""
    }
}


