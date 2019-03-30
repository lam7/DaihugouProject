//
//  User.swift
//  Daihugou
//
//  Created by Main on 2017/06/02.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import NCMB
import UIKit
import RxSwift

extension NCMBObject{
    func fetchInBackground(_ errorBlock: @escaping (_:Error?) -> (), _ block: @escaping () -> ()){
        fetchInBackground{ error in
            if let error = error{
                errorBlock(error)
                return
            }
            block()
        }
    }
}

extension Errors{
    class UserInfo{
        static let ncmbObjectFailure = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "エラー",
                                                                                           NSLocalizedFailureReasonErrorKey : "ncmbObjectFailure"])
        
        static let notEnough = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "購入エラー",
                                                                                   NSLocalizedFailureReasonErrorKey : "枚数が足りません"])
        static let overDeckNum = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ追加エラー",
                                                                                     NSLocalizedFailureReasonErrorKey : "これ以上デッキを追加することは出来ません"])
        static let notExistDeleteDeck = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ削除エラー",
                                                                                            NSLocalizedFailureReasonErrorKey : "そのデッキは存在しません"])
        static let notExistDeleteCard = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "カード削除エラー",
                                                                                            NSLocalizedFailureReasonErrorKey : "カードを所持しておりません"])
        static let alreadyCalledUpdate = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "更新エラー",
                                                                                             NSLocalizedFailureReasonErrorKey : "すでに更新済みです"])
        static let notExistGiftedItem = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "ギフトエラー",
                                                                                            NSLocalizedFailureReasonErrorKey : "そのギフトは存在しません"])
    }
}

extension Errors{
    class UserLogin{
        private static var _code = 0
        private static var code: Int{
            get{
                _code += 1
                return _code
            }
        }
        static let notExistUUID = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "エラー",
                                                                                      NSLocalizedFailureReasonErrorKey : "UUIDが取得できません"])
    }
}

typealias ErrorBlock = (_: Error?) -> ()

extension NCMBObject{
    func fetchObjectInBackground(_ completion: @escaping (Result<NCMBObject, Error>)->()){
        self.fetchInBackground{
            error in
            completion(.init(success: self, optionalFailure: error))
        }
    }
}

extension Result{
    init(success: Success, optionalFailure: Failure?){
        if let failure = optionalFailure{
            self = .failure(failure)
        }
        self = .success(success)
    }
}

class UserInfoUpdateServerModel{
    private var name: String?
    private var act: Int?
    private var gold: Int?
    private var crystal: Int?
    private var ticket: Int?
    private var cards: [Card]?
    private var removeCards: [Card]?
    private var deckIds: [String]?
    private var removeDeckIds: [String]?
    private var removeGiftIds: [String]?
    private var receivedGiftIds: [String]?
    private static let reservedupdateBlock = ControllAsyncBlock()
    private var isUpdating: Bool = false
    private var userInfo: NCMBObject!
    
    func fetchInBackground(_ completion: @escaping (Error?)->()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground{ error in
            let error = error ?? UserInfo.shared.update(object)
            completion(error)
        }
        self.userInfo = object
    }
    
    
    private func update(_ ncmbObject: NCMBObject)-> Error?{
        var error: Error?
        error = gainOrReduce(ncmbObject, id: "act", dif: act) ?? error
        error = gainOrReduce(ncmbObject, id: "gold", dif: gold) ?? error
        error = gainOrReduce(ncmbObject, id: "crystal", dif: crystal) ?? error
        error = gainOrReduce(ncmbObject, id: "ticket", dif: ticket) ?? error
        error = updateCards(ncmbObject) ?? error
        error = updateGift(ncmbObject) ?? error
        if let name = name{
            ncmbObject.setObject(name, forKey: "name")
        }
        return error
    }
    
    private func updateGift(_ ncmbObject: NCMBObject)-> Error?{
        var objectIds = ncmbObject.object(forKey: "giftedItemObjectIds") as! [String]
        for giftId in self.removeGiftIds ?? []{
            guard let index = objectIds.index(of: giftId) else{
                return Errors.UserInfo.notExistGiftedItem
            }
            objectIds.remove(at: index)
        }
        ncmbObject.setObject(objectIds, forKey: "giftedItemObjectIds")
        
        objectIds = ncmbObject.object(forKey: "receivedGiftedItemObjectIds") as! [String]
        (self.receivedGiftIds ?? []).forEach{
            objectIds.insert($0, at: 0)
        }
        let num = min(objectIds.count, MaxReceivedGiftedItemsNum)
        objectIds = objectIds[objectIds.count - num ..< num].map{ $0 }
        ncmbObject.setObject(objectIds, forKey: "receivedGiftedItemObjectIds")
        return nil
    }
    private func updateCards(_ ncmbObject: NCMBObject)-> Error?{
        var cardsIdCount = ncmbObject.object(forKey: "cardsIdCount") as! [[Int]]
        var cards = self.cards ?? []
        loop: for i in 0..<cards.count{
            for j in 0..<cardsIdCount.count{
                if cardsIdCount[j][0] == cards[i].id{
                    cardsIdCount[j][1] += 1
                    continue loop
                }
            }
            cardsIdCount.append([cards[i].id, 1])
        }
        cards = self.removeCards ?? []
        loop: for i in 0..<cards.count{
            for j in 0..<cardsIdCount.count{
                if cardsIdCount[j][0] == cards[i].id{
                    cardsIdCount[j][1] -= 1
                    if cardsIdCount[j][1] < 0{
                        cardsIdCount.remove(at: j)
                    }
                    continue loop
                }
            }
            return Errors.UserInfo.notExistDeleteCard
        }
        if self.removeCards != nil || self.cards != nil{
            cardsIdCount.sort(by: { $0.first! < $1.first! })
            ncmbObject.setObject(cardsIdCount, forKey: "cardsIdCount")
        }
        return nil
    }
    
    private func gainOrReduce(_ ncmbOjbect: NCMBObject, id: String, dif: Int?)-> Error?{
        guard let dif = dif else{
            return nil
        }
        let pos = ncmbOjbect.object(forKey: id) as! Int
        let sum = dif + pos
        if sum < 0{
            return Errors.UserInfo.notEnough
        }
        ncmbOjbect.setObject(sum, forKey: id)
        return nil
    }
    
    func save(_ completion: @escaping ErrorBlock){
        if isUpdating{
            completion(Errors.UserInfo.alreadyCalledUpdate)
            return
        }
        isUpdating = true
        UserInfoUpdateServerModel.reservedupdateBlock.add {
            self.userInfo.saveInBackground{ saveError in
                if let saveError = saveError{
                    completion(saveError)
                }
                completion(nil)
                UserInfo.shared.update(self.userInfo)
                UserInfoUpdateServerModel.reservedupdateBlock.next()
            }
        }
    }
    
    func fetchAndSave(_ completion: @escaping ErrorBlock){
        if isUpdating{
            completion(Errors.UserInfo.alreadyCalledUpdate)
            return
        }
        isUpdating = true
        UserInfoUpdateServerModel.reservedupdateBlock.add {
            self.fetchInBackground{ error in
                if let error = error{
                    completion(error)
                    UserInfoUpdateServerModel.reservedupdateBlock.next()
                    return
                }
                if let error = self.update(self.userInfo){
                    completion(error)
                    UserInfoUpdateServerModel.reservedupdateBlock.next()
                    return
                }
                self.userInfo.saveInBackground{ saveError in
                    if let saveError = saveError ?? UserInfo.shared.update(self.userInfo){
                        completion(saveError)
                    }
                    completion(nil)
                    UserInfoUpdateServerModel.reservedupdateBlock.next()
                }
            }
        }
    }
    
    private func updateServer(_ userInfo: NCMBObject, deck: Deck, completion: @escaping(Result<String, Error>)->()){
        guard let userDeck = NCMBObject(className: "userDeck") else{
            completion(.failure(Errors.UserInfo.ncmbObjectFailure))
            return
        }
        let deckObjectId = (deck as? DeckRelated)?.objectId
        let userInfoDecks = userInfo.object(forKey: "deckObjectIds") as! [String]
        if deckObjectId == nil && userInfoDecks.count + 1 >= MaxPossessionDecksNum{
            completion(.failure(Errors.UserInfo.overDeckNum))
        }
        let cards = deck.cards.sorted{ $0.id < $1.id }
        let ids = cards.map{ $0.id }
        let name = (deck as? DeckRelated)?.name ?? ""
        userDeck.setObject(ids, forKey: "cardsId")
        userDeck.setObject(UserLogin.objectIdUserInfo, forKey: "objectIdUserInfo")
        userDeck.setObject(name, forKey: "name")
        if let objectId = (deck as? DeckRelated)?.objectId{
            userDeck.objectId = objectId
        }
        
        userDeck.saveInBackground{
            error in
            completion(.init(success: userDeck.objectId, optionalFailure: error))
        }
    }
    
    @discardableResult
    func reduce(gold amount: UInt)-> UserInfoUpdateServerModel{
        self.gold = self.gold ?? 0 - amount
        return self
    }
    @discardableResult
    func reduce(crystal amount: UInt)-> UserInfoUpdateServerModel{
        self.crystal = self.crystal ?? 0 - amount
        return self
    }
    @discardableResult
    func reduce(ticket amount: UInt)-> UserInfoUpdateServerModel{
        self.ticket = self.ticket ?? 0 - amount
        return self
    }
    @discardableResult
    func gain(gold amount: UInt)-> UserInfoUpdateServerModel{
        self.gold = self.gold ?? 0 + amount
        return self
    }
    @discardableResult
    func gain(crystal amount: UInt)-> UserInfoUpdateServerModel{
        self.crystal = self.crystal ?? 0 + amount
        return self
    }
    @discardableResult
    func gain(ticket amount: UInt)-> UserInfoUpdateServerModel{
        self.ticket = self.ticket ?? 0 + amount
        return self
    }
    @discardableResult
    func append(cards: [Card])-> UserInfoUpdateServerModel{
        self.cards = self.cards ?? [] + cards
        return self
    }
    @discardableResult
    func remove(cards array: [Card])-> UserInfoUpdateServerModel{
        self.removeCards = self.removeCards ?? [] + array
        return self
    }
    @discardableResult
    func rename(player name: String)-> UserInfoUpdateServerModel{
        self.name = name
        return self
    }
    @discardableResult
    func receive(items: [GiftedItem])-> UserInfoUpdateServerModel{
        var `self` = self
        var items = items.filter{ $0.objectId != nil }
        for item in items{
            item.receive(&self)
        }
        var itemsId = items.map({ $0.objectId! })
        self.removeGiftIds = self.removeGiftIds ?? [] + itemsId
        self.receivedGiftIds = self.receivedGiftIds ?? [] + itemsId
        
        return self
    }
    @discardableResult
    func append(deck objectId: String)-> UserInfoUpdateServerModel{
        self.deckIds = self.deckIds ?? [] + objectId
        return self
    }
    @discardableResult
    func remove(deck objectId: String)-> UserInfoUpdateServerModel{
        self.removeDeckIds = self.removeDeckIds ?? [] + objectId
        return self
    }
    
    func clear()-> UserInfoUpdateServerModel{
        name = nil
        act = nil
        gold = nil
        crystal = nil
        ticket = nil
        cards = nil
        removeCards = nil
        isUpdating = false
        deckIds = nil
        removeDeckIds = nil
        removeGiftIds = nil
        receivedGiftIds = nil
        return self
    }
}
class UserInfo{
    private var nameVar = Variable("")
    private var actVar = Variable(0)
    private var goldVar = Variable(0)
    private var crystalVar = Variable(0)
    private var ticketVar = Variable(0)
    private var deckIdsVar: Variable<[String]> = Variable([])
    private var cardsVar: Variable<CardCount> = Variable([:])
    private var giftedIdsVar: Variable<[String]> = Variable([])
    private var receivedGiftedIdsVar: Variable<[String]> = Variable([])
    
    var name: Observable<String>{ return nameVar.asObservable() }
    var act: Observable<Int>{ return actVar.asObservable() }
    var gold: Observable<Int>{ return goldVar.asObservable() }
    var crystal: Observable<Int>{ return crystalVar.asObservable() }
    var ticket: Observable<Int>{ return ticketVar.asObservable() }
    var deckIds: Observable<[String]>{ return deckIdsVar.asObservable() }
    var cards: Observable<CardCount>{ return cardsVar.asObservable() }
    var giftedIds: Observable<[String]>{ return giftedIdsVar.asObservable() }
    var receivedGiftedIds: Observable<[String]>{ return receivedGiftedIdsVar.asObservable() }
    
    var nameValue: String{ return nameVar.value }
    var actValue: Int{ return actVar.value }
    var goldValue: Int{ return goldVar.value }
    var crystalValue: Int{ return crystalVar.value }
    var ticketValue: Int{ return ticketVar.value }
    var deckIdsValue: [String]{ return deckIdsVar.value }
    var cardsValue: CardCount{ return cardsVar.value }
    var giftedIdsValue: [String]{ return giftedIdsVar.value }
    var receivedGiftedIdsValue: [String]{ return receivedGiftedIdsVar.value }
    
    static var shared = UserInfo()
    
    private init(){}
    
    func update(_ object: NCMBObject)-> Error?{
        guard let name = object.object(forKey: "name") as? String,
            let act = object.object(forKey: "act") as? Int,
            let gold = object.object(forKey: "gold") as? Int,
            let crystal = object.object(forKey: "crystal") as? Int,
            let ticket = object.object(forKey: "ticket") as? Int,
            let deckIds = object.object(forKey: "deckObjectIds") as? [String],
            let cardsIdCount = object.object(forKey: "cardsIdCount") as? [[Int]],
            let giftedIds = object.object(forKey: "giftedItemObjectIds") as? [String],
            let receivedGiftedIds = object.object(forKey: "receivedGiftedItemObjectIds") as? [String] else{
                return Errors.UserInfo.ncmbObjectFailure
        }
        let convert = self.convertCardCount(from: cardsIdCount)
        if let error = convert.0{
            return error
        }
        self.nameVar.value    = name
        self.actVar.value     = act
        self.goldVar.value    = gold
        self.crystalVar.value = crystal
        self.ticketVar.value  = ticket
        self.deckIdsVar.value = deckIds
        self.cardsVar.value = convert.1
        self.giftedIdsVar.value = giftedIds
        self.receivedGiftedIdsVar.value = receivedGiftedIds
        return nil
    }
    
    func update(_ completion: ErrorBlock? = nil){
        guard let object = NCMBObject(className: "userInfo") else{
            completion?(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error ?? self.update(object){
                completion?(error)
                return
            }
            completion?(nil)
        }
    }
    
    private func fetchAndUpdate(_ update: @escaping (NCMBObject)->(), completion: @escaping ErrorBlock){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground{ error in
            if let error = error{
                completion(error)
                return
            }
            update(object)
            object.saveInBackground{ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.nameVar.value    = object.object(forKey: "name") as! String
                self.actVar.value     = object.object(forKey: "act") as! Int
                self.goldVar.value    = object.object(forKey: "gold") as! Int
                self.crystalVar.value = object.object(forKey: "crystal") as! Int
                self.ticketVar.value  = object.object(forKey: "ticket") as! Int
                self.deckIdsVar.value = object.object(forKey: "deckObjectIds") as! [String]
                let cardsIdCount = object.object(forKey: "cardsIdCount") as! [[Int]]
                let convert = self.convertCardCount(from: cardsIdCount)
                if let error = convert.0{
                    completion(error)
                    return
                }
                self.cardsVar.value = convert.1
            }
        }
    }
    
    func reduce(crystal amount: Int, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().reduce(crystal: UInt(amount)).fetchAndSave(completion)
    }
    func reduce(ticket amount: Int, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().reduce(ticket: UInt(amount)).fetchAndSave(completion)
    }
    func reduce(gold amount: Int, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().reduce(gold: UInt(amount)).fetchAndSave(completion)
    }
    func gain(crystal amount: Int, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().gain(crystal: UInt(amount)).fetchAndSave(completion)
    }
    func gain(ticket amount: Int, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().gain(ticket: UInt(amount)).fetchAndSave(completion)
    }
    func gain(gold amount: Int, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().gain(gold: UInt(amount)).fetchAndSave(completion)
    }
    func append(cards: [Card], completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().append(cards: cards).fetchAndSave(completion)
    }
    func remove(cards: [Card], completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().remove(cards: cards).fetchAndSave(completion)
    }
    func rename(player name: String, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().rename(player: name).fetchAndSave(completion)
    }
    private func append(deck: String, completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().append(deck: deck).fetchAndSave(completion)
    }
    
    /// 作成されたデッキをサーバー側に送る
    func append(deck: Deck, completion: @escaping ErrorBlock){
        guard let userDeck = NCMBObject(className: "userDeck") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        let model = UserInfoUpdateServerModel()
        model.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            let deckObjectId = (deck as? DeckRelated)?.objectId
            if deckObjectId == nil{
                guard self.deckIdsValue.count < MaxPossessionDecksNum else{
                    completion(Errors.UserInfo.overDeckNum)
                    return
                }
            }
            let cards = deck.cards.sorted{ $0.id < $1.id }
            let ids = cards.map{ $0.id }
            let name = (deck as? DeckRelated)?.name ?? ""
            userDeck.setObject(ids, forKey: "cardsId")
            userDeck.setObject(UserLogin.objectIdUserInfo, forKey: "objectIdUserInfo")
            userDeck.setObject(name, forKey: "name")
            if let objectId = deckObjectId{
                userDeck.objectId = objectId
            }
            userDeck.saveInBackground{
                saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                
                if deckObjectId != nil{
                    completion(nil)
                    return
                }
                model.append(deck: userDeck.objectId).fetchAndSave(completion)
            }
        }
    }
    
    
    func get(deck objectId: String, completion: @escaping (_ deck: Deck?, _: Error?) -> ()){
        guard let userDeck = NCMBObject(className: "userDeck") else{
            completion(nil, Errors.UserInfo.ncmbObjectFailure)
            return
        }
        
        userDeck.objectId = objectId
        userDeck.fetchInBackground{
            error in
            if let error = error{
                completion(nil, error)
                return
            }
            let cardsId = userDeck.object(forKey: "cardsId") as! [Int]
            let cards = cardsId.map({ CardList.get(id: $0 )})
            if !cards.filter({ $0 == nil }).isEmpty{
                print("Not Exist Card \(cards)")
                completion(nil, Errors.Card.notExistCardId(nil))
            }
            let name = userDeck.object(forKey: "name") as! String
            let deck = DeckRelated(cards: cards.compactMap({ $0 }))
            deck.objectId = objectId
            deck.name = name
            completion(deck, nil)
        }
    }
    
    func getAllDeck(_ completion: @escaping (_ decks: [Deck], _: Error?) -> ()){
        guard let userInfo = NCMBObject(className: "userInfo"),
            let userDeck = NCMBQuery(className: "userDeck") else{
                completion([], Errors.UserInfo.ncmbObjectFailure)
                return
        }
        userInfo.objectId = UserLogin.objectIdUserInfo
        var decks: [Deck] = []
        userInfo.fetchInBackground(){ error in
            if let error = error{
                completion([], error)
                return
            }
            let deckIds = userInfo.object(forKey: "deckObjectIds") as! [String]
            userDeck.whereKey("objectId", containedIn: deckIds)
            userDeck.findObjectsInBackground{
                objects, error in
                if let error = error{
                    completion([], error)
                    return
                }
                guard let objects = objects else{
                    completion([], Errors.UserInfo.ncmbObjectFailure)
                    return
                }
                
                for object in objects{
                    guard let obj = object as? NCMBObject else{
                        print("UserInfo-getAllDeck object Error")
                        continue
                    }
                    let cardsId = obj.object(forKey: "cardsId") as! [Int]
                    let cards = cardsId.map({ CardList.get(id: $0 )})
                    if !cards.filter({ $0 == nil}).isEmpty{
                        print("Not Exist Card \(cards)")
                        continue
                    }
                    
                    let name = obj.object(forKey: "name") as! String
                    let deck = DeckRelated(cards: cards.compactMap({ $0 }))
                    deck.objectId = obj.objectId
                    deck.name = name
                    decks.append(deck)
                }
                completion(decks, nil)
            }
        }
    }
    
    func remove(deck objectId: String, completion: @escaping ErrorBlock){
        guard let userDeck = NCMBObject(className: "userDeck"),
            let userInfo = NCMBObject(className: "userInfo") else{
                completion(Errors.UserInfo.ncmbObjectFailure)
                return
        }
        userInfo.objectId = UserLogin.objectIdUserInfo
        userInfo.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var deckIds = userInfo.object(forKey: "deckObjectIds") as! [String]
            guard let index = deckIds.firstIndex(of: objectId) else{
                completion(Errors.UserInfo.notExistDeleteDeck)
                return
            }
            deckIds.remove(at: index)
            userInfo.setObject(deckIds, forKey: "deckObjectIds")
            userInfo.saveInBackground{
                [weak self] saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self?.deckIdsVar.value = deckIds
                
                userDeck.objectId = objectId
                userDeck.deleteInBackground(completion)
            }
        }
    }
    
    
    func gift(item: GiftedItem, completion: @escaping ErrorBlock){
        guard let userInfo = NCMBObject(className: "userInfo"),
            let giftedItem = NCMBObject(className: "giftedItem") else{
                completion(Errors.UserInfo.ncmbObjectFailure)
                return
        }
        
        userInfo.objectId = UserLogin.objectIdUserInfo
        giftedItem.setObject(item.id, forKey: "id")
        giftedItem.setObject(item.subId, forKey: "subId")
        giftedItem.setObject(item.count, forKey: "count")
        giftedItem.setObject(item.description, forKey: "description")
        giftedItem.setObject(item.title, forKey: "title")
        giftedItem.setObject(item.imageNamed, forKey: "imageNamed")
        giftedItem.setObject(item.timeLimit, forKey: "timeLimit")
        giftedItem.setObject(item.timeStamp, forKey: "timeStamp")
        giftedItem.setObject(UserLogin.objectIdUserInfo, forKey: "objectIdUserInfo")
        giftedItem.setObject(false, forKey: "isReceived")
        giftedItem.saveInBackground{
            saveError in
            if let saveError = saveError{
                completion(saveError)
                return
            }
            
            userInfo.fetchInBackground{
                error in
                if let error = error{
                    completion(error)
                    return
                }
                var giftedIds = userInfo.object(forKey: "giftedItemObjectIds") as! [String]
                giftedIds.append(giftedItem.objectId)
                userInfo.setObject(giftedIds, forKey: "giftedItemObjectIds")
                userInfo.saveInBackground{
                    saveError in
                    completion(saveError)
                }
            }
        }
    }
    
    func receive(items: [GiftedItem], completion: @escaping ErrorBlock){
        UserInfoUpdateServerModel().receive(items: items).fetchAndSave(completion)
    }
    
    func getAllGiftedItemInfos(_ completion: @escaping(Result<(giftedItem: [GiftedItem], receivedGiftedItem: [GiftedItem]), Error>)->()){
        guard let giftedItem = NCMBQuery(className: "giftedItem") else{
            completion(.failure(Errors.UserInfo.ncmbObjectFailure))
            return
        }
        let userInfo = UserInfoUpdateServerModel()
        userInfo.fetchInBackground{ error in
            if let error = error{
                completion(.failure(error))
                return
            }
            giftedItem.whereKey("objectId", containedIn: self.giftedIdsValue + self.receivedGiftedIdsValue)
            giftedItem.findObjectsInBackground{ objects,error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
                let objects = objects as! [NCMBObject]
                var giftedItems: [GiftedItem] = []
                var receivedGiftedItems: [GiftedItem] = []
                for obj in objects{
                    guard let timeStamp = obj.object(forKey: "timeStamp") as? Date,
                        let timeLimit = obj.object(forKey: "timeLimit") as? Date,
                        timeLimit.compare(Date()) == ComparisonResult.orderedDescending,
                        let id = obj.intValue(forKey: "id"),
                        let subId = obj.intValue(forKey: "subId"),
                        let description = obj.object(forKey: "description") as? String,
                        let count = obj.intValue(forKey: "count"),
                        let imageNamed = obj.object(forKey: "imageNamed") as? String,
                        let objectId = obj.objectId,
                        var giftedItem = try? GiftedItem(objectId: objectId, timeStamp: timeStamp, timeLimit: timeLimit, id: id, subId: subId, description: description, count: count, imageNamed: imageNamed) else{
                            fatalError("object Error")
                    }
                    if self.giftedIdsValue.contains(objectId){
                        giftedItem.isReceived = false
                        giftedItems.append(giftedItem)
                    }else{
                        giftedItem.isReceived = true
                        receivedGiftedItems.append(giftedItem)
                    }
                }
                completion(.success((giftedItems, receivedGiftedItems)))
            }
        }
    }
    
    private func convertCardCount(from cardsIdCount: [[Int]])-> (Error?, CardCount){
        var cards: CardCount = [:]
        for cardIdCount in cardsIdCount{
            guard let card = CardList.get(id: cardIdCount[0]) else{
                return (Errors.Card.notExistCardId(cardIdCount[0]), cards)
            }
            cards[card] = cardIdCount[1]
            //            if cards[card] != nil{
            //                cards[card]! += 1
            //            }else{
            //                cards[card] = 1
            //            }
        }
        
        return (nil, cards)
    }
}

class UserLogin{
    private(set) static var uuid: String!
    
    private(set) static var objectIdUserInfo: String!
    
    private init(){
    }
    
    static func localLogin(completion: @escaping ErrorBlock){
        completion(nil)
    }
    
    static func login(completion: @escaping ErrorBlock){
        uuid = UIDevice.current.identifierForVendor?.uuidString
        if uuid == nil{
            completion(Errors.UserLogin.notExistUUID)
            return
        }
        /* mBaaSログイン */
        NCMBUser.logInWithUsername(inBackground: uuid, password: uuid) { user, loginError in
            if let loginError = loginError{
                // ログイン失敗時の処理
                let login_err : NSError = loginError as NSError
                // 初回利用（会員未登録）の場合
                if login_err.code == 401002 { // 401002：ID/Pass認証エラー
                    //初回会員登録を実行する
                    UserLogin.signUp(){
                        signUpError in
                        // エラーが起きたなら
                        if let signUpError = signUpError{
                            completion(signUpError)
                            return
                        }
                        // 再ログインをする
                        self.login(){ reLoginError in
                            let timeStamp = Date()
                            let d = 60 * 60 * 24 * 365
                            let timeLimit = timeStamp.addingTimeInterval(TimeInterval(d))
                            let giftItemInfo1 = try! GiftedItem(timeStamp: timeStamp, timeLimit: timeLimit, id: 1, subId: 999999, description: "初回プレゼント", count: 1, imageNamed: "TreasureChest.png")
                            let giftItemInfo2 = try! GiftedItem(timeStamp: timeStamp, timeLimit: timeLimit, id: 2, subId: 999999, description: "初回プレゼント", count: 1, imageNamed: "TreasureChest.png")
                            UserInfo.shared.gift(item: giftItemInfo2){ giftError in
                                UserInfo.shared.gift(item: giftItemInfo1){ _ in }
                                completion(giftError)
                            }
                        }
                    }
                }
                return
            }
            // ログイン成功時の処理
            print("ログインに成功しました")
            loginSuccess(user, completion: completion)
        }
    }
    
    /// ログイン成功時の処理
    private static func loginSuccess(_ user: NCMBUser?, completion: @escaping (_ error: Error?) -> ()){
        let updateDate = user?.updateDate
        user?.setObject(updateDate, forKey: "lastLoginDate")
        
        user?.saveInBackground(){ saveError in
            if let saveError = saveError {
                // 保存失敗時の処理
                let save_err = saveError as NSError
                print("最終ログイン日時の保存に失敗しました。エラーコード：\(save_err.code)")
                completion(save_err)
                return
            }
            
            // 保存成功時の処理
            print("最終ログイン日時の保存に成功しました。")
            let id = user?.object(forKey: "objectIdUserInfo") as? String
            objectIdUserInfo = id
            completion(nil)
        }
    }
    
    ///　初回会員登録
    ///
    /// - FIXME: userInfo.saveとnewUser.saveInBackgroundの中間でアプリが落ちた時，不完全なデータが出来上がってしまうかもしれないので直す
    /// - TODO: これらの処理をjsにしてサーバー側で処理をさせる
    private static func signUp(completion: @escaping ErrorBlock){
        let newUser = NCMBUser()
        newUser.userName = uuid
        newUser.password = uuid
        
        newUser.signUpInBackground(){ signUpError in
            if let signUpError = signUpError{
                completion(signUpError)
                return
            }
            
            let userInfo = NCMBObject(className: "userInfo")
            userInfo?.setObject(10000, forKey: "gold")
            userInfo?.setObject(10000, forKey: "crystal")
            userInfo?.setObject(10, forKey: "ticket")
            userInfo?.setObject("", forKey: "name")
            userInfo?.setObject("", forKey: "deck")
            userInfo?.setObject([Int]([]), forKey: "deckObjectIds")
            let cardsIdCount: [[ Int ]] = []
            userInfo?.setObject(cardsIdCount, forKey: "cardsIdCount")
            userInfo?.setObject(10, forKey: "act")
            userInfo?.setObject([], forKey: "giftedItemObjectIds")
            userInfo?.setObject([], forKey: "receivedGiftedItemObjectIds")
            userInfo?.saveInBackground(){
                userInfoError in
                if let userInfoError = userInfoError{
                    completion(userInfoError)
                    return
                }
                newUser.setObject(userInfo?.objectId, forKey: "objectIdUserInfo")
                newUser.saveInBackground(){
                    saveError in
                    completion(saveError)
                }
            }
        }
    }
}
