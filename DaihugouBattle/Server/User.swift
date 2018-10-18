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
                                                                                                      NSLocalizedFailureReasonErrorKey : "エラーコード\(_code)"])
        
        static let notEnoughGold = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "購入エラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "ゴールドの枚数が足りません"])
        
        static let notEnoughCrystal = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "購入エラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "クリスタルの枚数が足りません"])
        
        static let notEnoughTicket = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "購入エラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "チケットの枚数が足りません"])
        
        static let gainMinus = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "エラー",
                                                                                  NSLocalizedFailureReasonErrorKey : "エラーコード\(_code)"])
        static let overDeckNum = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ追加エラー",
                                                                                   NSLocalizedFailureReasonErrorKey : "これ以上デッキを追加することは出来ません"])
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

class UserInfo{
    private var nameVar = Variable("")
    private var actVar = Variable(0)
    private var goldVar = Variable(0)
    private var crystalVar = Variable(0)
    private var ticketVar = Variable(0)
    private var deckIdsVar: Variable<[String]> = Variable([])
    private var cardsVar: Variable<CardCount> = Variable([:])
    
    var name: Observable<String>{ return nameVar.asObservable() }
    var act: Observable<Int>{ return actVar.asObservable() }
    var gold: Observable<Int>{ return goldVar.asObservable() }
    var crystal: Observable<Int>{ return crystalVar.asObservable() }
    var ticket: Observable<Int>{ return ticketVar.asObservable() }
    var deckIds: Observable<[String]>{ return deckIdsVar.asObservable() }
    var cards: Observable<CardCount>{ return cardsVar.asObservable() }
    
    var nameValue: String{ return nameVar.value }
    var actValue: Int{ return actVar.value }
    var goldValue: Int{ return goldVar.value }
    var crystalValue: Int{ return crystalVar.value }
    var ticketValue: Int{ return ticketVar.value }
    var deckIdsValue: [String]{ return deckIdsVar.value }
    var cardsValue: CardCount{ return cardsVar.value }
    
    static var shared = UserInfo()
    
    private init(){}
    
    func localUpdate(){
        nameVar.value = "ローカル"
        actVar.value = Int.max
        goldVar.value = Int.max
        crystalVar.value = Int.max
        ticketVar.value = Int.max
        CardList.list.forEach{
            self.cardsVar.value[$0] = 99
        }
    }
    
    func update(_ completion: ((_: Error?) -> ())? = nil){
        
        guard let object = NCMBObject(className: "userInfo") else{
            completion?(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion?(error)
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
                completion?(error)
                return
            }
            self.cardsVar.value = convert.1
            completion?(nil)
        }
    }
    
    func reduce(gold: Int, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfGold = object.object(forKey: "gold") as! Int
            if selfGold - gold < 0{
                completion(Errors.UserInfo.notEnoughGold)
                return
            }
            selfGold -= gold
            object.setObject(selfGold, forKey: "gold")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.goldVar.value = object.object(forKey: "gold") as! Int
                completion(nil)
            }
        }
    }
    
    func reduce(crystal: Int, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfCrystal = object.object(forKey: "crystal") as! Int
            if selfCrystal - crystal < 0{
                completion(Errors.UserInfo.notEnoughCrystal)
                return
            }
            selfCrystal -= crystal
            object.setObject(selfCrystal, forKey: "crystal")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.crystalVar.value = object.object(forKey: "crystal") as! Int
                completion(nil)
            }
        }
    }
    
    
    func reduce(ticket: Int, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfTicket = object.object(forKey: "ticket") as! Int
            if selfTicket - ticket < 0{
                completion(Errors.UserInfo.notEnoughTicket)
                return
            }
            selfTicket -= ticket
            object.setObject(selfTicket, forKey: "ticket")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.ticketVar.value = object.object(forKey: "ticket") as! Int
                completion(nil)
            }
        }
    }
    
    func gain(gold amount: Int, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        if amount < 0{
            completion(Errors.UserInfo.gainMinus)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfGold = object.object(forKey: "gold") as! Int
            selfGold += amount
            object.setObject(selfGold, forKey: "gold")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.goldVar.value = object.object(forKey: "gold") as! Int
                completion(nil)
//                self.update(completion)
            }
        }
    }
    
    func gain(crystal amount: Int, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        if amount < 0{
            completion(Errors.UserInfo.gainMinus)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfCrystal = object.object(forKey: "crystal") as! Int
            selfCrystal += amount
            object.setObject(selfCrystal, forKey: "crystal")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.crystalVar.value = object.object(forKey: "crystal") as! Int
                completion(nil)
//                self.update(completion)
            }
        }
    }
    
    
    func gain(ticket amount: Int, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        if amount < 0{
            completion(Errors.UserInfo.gainMinus)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfTicket = object.object(forKey: "ticket") as! Int
            selfTicket += amount
            object.setObject(selfTicket, forKey: "ticket")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.ticketVar.value = object.object(forKey: "ticket") as! Int
                completion(nil)
//                self.update(completion)
            }
        }
    }
    
    /// 取得したカードをサーバー側に送る
    func append(cards: [Card], completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            var selfCardsIdCount = object.object(forKey: "cardsIdCount") as! [[Int]]
            loop: for i in 0..<cards.count{
                for j in 0..<selfCardsIdCount.count{
                    if selfCardsIdCount[j][0] == cards[i].id{
                        selfCardsIdCount[j][1] += 1
                        continue loop
                    }
                }
                selfCardsIdCount.append([cards[i].id, 1])
            }
            selfCardsIdCount.sort(by: { $0.first! < $1.first! })
            object.setObject(selfCardsIdCount, forKey: "cardsIdCount")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                let cardsIdCount = object.object(forKey: "cardsIdCount") as! [[Int]]
                let convert = self.convertCardCount(from: cardsIdCount)
                if let error = convert.0{
                    completion(error)
                    return
                }
                self.cardsVar.value = convert.1
                completion(nil)
            }
        }
    }
    
    /// 作成されたデッキをサーバー側に送る
    func append(deck: Deck, completion: @escaping (_: Error?) -> ()){
        guard let userInfo = NCMBObject(className: "userInfo"),
            let userDeck = NCMBObject(className: "userDeck") else{
                completion(Errors.UserInfo.ncmbObjectFailure)
                return
        }
        let deckObjectId = (deck as? DeckRelated)?.objectId
        if deckObjectId == nil{
            guard UserInfo.shared.deckIdsValue.count + 1 < MaxPossessionDecksNum else{
                completion(Errors.UserInfo.overDeckNum)
                return
            }
        }
        userInfo.objectId = UserLogin.objectIdUserInfo
        let cards = deck.cards.sorted{ $0.id < $1.id }
        let ids = cards.map{ $0.id }
        let name = deck.name
        userDeck.setObject(ids, forKey: "cardsId")
        userDeck.setObject(UserLogin.objectIdUserInfo, forKey: "objectIdUserInfo")
        userDeck.setObject(name, forKey: "name")
        if let objectId = (deck as? DeckRelated)?.objectId{
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
            userInfo.fetchInBackground{
                error in
                if let error = error{
                    completion(error)
                    return
                }
                var deckIds = userInfo.object(forKey: "deckObjectIds") as! [String]
                deckIds.append(userDeck.objectId)
                userInfo.setObject(deckIds, forKey: "deckObjectIds")
                userInfo.saveInBackground{
                    saveError in
                    if let saveError = saveError{
                        completion(saveError)
                        return
                    }
                    self.deckIdsVar.value = userInfo.object(forKey: "deckObjectIds") as! [String]
                    completion(nil)
                }
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
            let deck = DeckRelated(cards: cards.compactMap({ $0 }), name: name)
            deck.objectId = objectId
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
                    let deck = DeckRelated(cards: cards.compactMap({ $0 }), name: name)
                    deck.objectId = obj.objectId
                    decks.append(deck)
                }
                completion(decks, nil)
            }
        }
    }
    
//    func getAllDeck(_ completion: @escaping (_ decks: [Deck?], _: Error?) -> ()){
//        guard let userInfo = NCMBObject(className: "userInfo"),
//            let userDeck = NCMBQuery(className: "userDeck") else{
//            completion([], Errors.UserInfo.ncmbObjectFailure)
//            return
//        }
//        userInfo.objectId = UserLogin.objectIdUserInfo
//        var decks: [Deck?] = []
//        print("getDecks")
//        userInfo.fetchInBackground(){ error in
//            if let error = error{
//                completion([], error)
//                return
//            }
//            let deckIds = userInfo.object(forKey: "deckObjectIds") as! [String]
//            let decksAllNil = [Deck?](repeating: nil, count: deckIds.count)
//            let deckIdsNotNull = deckIds.filter({$0 != "NULL"})
//            if deckIdsNotNull.isEmpty{
//                completion(decksAllNil, nil)
//                return
//            }
//            userDeck.whereKey("objectId", containedIn: deckIdsNotNull)
//            userDeck.findObjectsInBackground{
//                objects, error in
//                if let error = error{
//                    completion(decksAllNil, error)
//                    return
//                }
//                guard let objects = objects else{
//                    completion(decksAllNil, Errors.UserInfo.ncmbObjectFailure)
//                    return
//                }
//
//                for object in objects{
//                    guard let obj = object as? NCMBObject else{
//                        print("UserInfo-getAllDeck object Error")
//                        decks.append(nil)
//                        continue
//                    }
//                    let cardsId = obj.object(forKey: "cardsId") as! [Int]
//                    let cards = cardsId.map({ CardList.get(id: $0 )})
//                    if !cards.filter({ $0 == nil}).isEmpty{
//                        print("Not Exist Card \(cards)")
//                        decks.append(nil)
//                        continue
//                    }
//
//                    let name = obj.object(forKey: "name") as! String
//                    print("name\(name)")
//                    print("deck")
//                    let deck = Deck(cards: cards.compactMap({ $0 }), name: name)
//                    decks.append(deck)
//                }
//                completion(decks, nil)
//            }
//        }
//    }
    
    
    func gift(item: GiftItemInfo, completion: @escaping (_: Error?) -> ()){
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
    
    func delete(giftItem objectId: String, completion: @escaping (_: Error?) -> ()){
        guard let userInfo = NCMBObject(className: "userInfo"),
            let giftedItem = NCMBObject(className: "giftedItem") else{
                completion(Errors.UserInfo.ncmbObjectFailure)
                return
        }
        userInfo.objectId = UserLogin.objectIdUserInfo
        giftedItem.objectId = objectId
        giftedItem.setObject(true, forKey: "isReceived")
        userInfo.fetchInBackground{
            error in
            if let error = error{
                completion(error)
                return
            }
            var gifts = userInfo.object(forKey: "giftedItemObjectIds") as! [String]
            gifts.removeAll(objectId)
            userInfo.setObject(gifts, forKey: "giftedItemObjectIds")
            userInfo.saveInBackground{
                saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                giftedItem.saveInBackground{
                    error in
                    completion(error)
                }
            }
        }
    }
    
    func rename(player name: String, completion: @escaping (_: Error?) -> ()){
        guard let object = NCMBObject(className: "userInfo") else{
            completion(Errors.UserInfo.ncmbObjectFailure)
            return
        }
        object.objectId = UserLogin.objectIdUserInfo
        object.fetchInBackground(){ error in
            if let error = error{
                completion(error)
                return
            }
            object.setObject(name, forKey: "name")
            object.saveInBackground(){ saveError in
                if let saveError = saveError{
                    completion(saveError)
                    return
                }
                self.nameVar.value = object.object(forKey: "name") as! String
                completion(nil)
//                self.update(completion)
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
    
    static func localLogin(completion: @escaping (_: Error?) -> ()){
        completion(nil)
    }
    
    static func login(completion: @escaping (_: Error?) -> ()){
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
                            completion(reLoginError)
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
    private static func signUp(completion: @escaping (_: Error?) -> ()){
        let newUser = NCMBUser()
        newUser.userName = uuid
        newUser.password = uuid
        
        newUser.signUpInBackground(){ signUpError in
            if let signUpError = signUpError{
                completion(signUpError)
                return
            }
            
            let userInfo = NCMBObject(className: "userInfo")
            userInfo?.setObject(1000, forKey: "gold")
            userInfo?.setObject(1000, forKey: "crystal")
            userInfo?.setObject(10, forKey: "ticket")
            userInfo?.setObject("", forKey: "name")
            userInfo?.setObject("", forKey: "card")
            userInfo?.setObject("", forKey: "deck")
            userInfo?.setObject([Int]([]), forKey: "deckObjectIds")
            let cardsIdCount: [[ Int ]] = []
            userInfo?.setObject(cardsIdCount, forKey: "cardsIdCount")
            userInfo?.setObject(10, forKey: "act")
            userInfo?.setObject([], forKey: "giftedItemObjectIds")
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

