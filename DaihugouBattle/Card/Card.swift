//
//  Card.swift
//  Daihugou
//
//  Created by Main on 2017/05/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import NCMB
import RxSwift
import RxCocoa
import SwiftyJSON


///スタンダートカードのインデックス範囲
let StandartCardIndexRange = 1...10
///全カードのインデックス範囲
let AllCardIndexRange = 1...10
///ジョーカーのインデックス
let JokerIndex = 0

//typealias CardCount = (card: Card, count: Int)
typealias CardCount = [Card : Int]
typealias CardCountTaple = (Card, Int)
func convertCardArray(_ cardCount: CardCount)-> [Card]{
    var cards: [Card] = []
    cardCount.forEach{
        arg in
        (0..<arg.value).forEach{_ in
            cards.append(arg.key.copy() as! Card)
        }
    }
    return cards
}

func convertCardCount(_ cardArray: [Card])-> CardCount{
    var cardCount: CardCount = [:]
    cardArray.forEach({ cardCount += $0 })
    return cardCount
}

func +=(lhs: inout CardCount, rhs: Card){
    if lhs[rhs] == nil{
        lhs[rhs] = 1
    }else{
        lhs[rhs]! += 1
    }
}

func -=(lhs: inout CardCount, rhs: Card){
    if lhs[rhs] != nil{
        lhs[rhs]! -= 1
        if lhs[rhs]! <= 0{
            lhs[rhs] = nil
        }
    }
}

func +=(lhs: inout CardCount, rhs: CardCount){
    var l = lhs
    for r in rhs{
        var c = l[r.key] ?? 0
        c += r.value
        l[r.key] = c
    }
    lhs = l
}

func -=(lhs: inout CardCount, rhs: CardCount){
    var l = lhs
    for r in rhs{
        var c = l[r.key] ?? 0
        c -= r.value
        if c <= 0{
            l[r.key] = nil
        }else{
            l[r.key] = c
        }
    }
    lhs = l
}

extension Errors{
    class Card{        
        static let notExistCardId: ((Int?) -> (NSError)) = {
            id in
            var reason = "そのカードは存在しません"
            if let id = id{
                reason += "(\(id)"
            }
            return NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "カードエラー",
                                                                NSLocalizedFailureReasonErrorKey : reason])
        }
    }
}

/// カードレアリティ
///
/// UR, SR, R, N
enum CardRarity: String, CaseIterable{
    case UR, SR, R, N
}

class Card: Equatable, Hashable, NSCopying{
    ///カードid
    fileprivate(set) var id: Int
    ///名前
    fileprivate(set) var name: String
    ///カード画像名
    fileprivate(set) var imageNamed: String
    ///カードの数字
    fileprivate(set) var index: Int
    ///体力
    fileprivate(set) var hp: Int
    ///攻撃力
    fileprivate(set) var atk: Int
    ///レアリティ
    fileprivate(set) var rarity: CardRarity
    
    fileprivate(set) var skills: [Skill]
    var hashValue: Int{
        return id.hashValue ^ hp.hashValue ^ atk.hashValue ^ index.hashValue
    }
    
    /// キャラ画像
    var image: UIImage?{
        return RealmImageCache.shared.image(imageNamed)
//        return DataRealm.get(imageNamed: imageNamed)
    }
    
    /// 最初のカード生成時の時のためのイニシャライザ
    fileprivate init(id: Int, name: String, imageNamed: String, rarity: String, index: Int, hp: Int, atk: Int, skills: [Skill]){
        self.id = id
        self.name = name
        self.imageNamed = imageNamed
        self.rarity = CardRarity(rawValue: rarity)!
        self.index = index
        self.hp = hp
        self.atk = atk
        self.skills = skills
    }
    
    /// カードの複製を作る
    ///
    /// - Parameter card: 複製するカード
    required init(card: Card){
        self.id = card.id
        self.name = card.name
        self.imageNamed = card.imageNamed
        self.rarity = card.rarity
        self.index = card.index
        self.hp = card.hp
        self.atk = card.atk
        self.skills = card.skills
    }
    
    func equal(_ to: Card)-> Bool{
        let id         = self.id == to.id
        let name       = self.name == to.name
        let imageNamed = self.imageNamed == to.imageNamed
        let index      = self.index == to.index
        let hp         = self.hp == to.hp
        let atk        = self.atk == to.atk
        let rarity     = self.rarity == to.rarity
        return id && name && imageNamed && index && hp && atk && rarity
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.equal(rhs) && rhs.equal(lhs)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let card = Card(card: self)
        return card
    }
}

var cardNoData: Card{
    return Card(id: 0, name: "", imageNamed: "", rarity: "N", index: 0, hp: 0, atk: 0, skills: [Skill()])
}

class CardList{
    private static var cards:[Card] = []
    private init(){}
    public static var cardsCount: Int{
        return cards.count
    }
    
    /// 配列のn番目のカードを返す
    /// -TODO:　いずれ消すこと
    public static func get(_ n: Int)-> Card?{
        if !CardList.cards.inRange(n){
            return nil
        }
        let card = CardList.cards[n]
        return Card(card: card)
    }
    
    
    /// 指定idのカードを返す
    ///
    /// - Parameter id: id
    /// - Returns: カード
    public static func get(id: Int)-> Card?{
        for c in cards{
            if c.id == id{
                return Card(card: c)
            }
        }
        return nil
    }
    
    
    /// ランダムにカードを返す
    static var random: Card{
        return cards[cards.count.random]
    }
    
    /// カード一覧を返す
    static var list: [Card]{
        var copy: [Card] = []
        cards.forEach{ copy.append($0.copy() as! Card) }
        return copy
    }
    
    /// カードの初期化
    /// -　起動毎に通信しカード情報を得る
    public static func loadProperty(completion: @escaping ErrorBlock){
        //サーバーからカード情報を取得
        //maxは1000なので，これを超えたらサーバー側にクラスを追加
        SkillList.loadProperty{
            error in
            if let error = error{
                completion(error)
                return
            }
            print("loadProperty CardList")
            let query = NCMBQuery(className: "cardInfo")
            query?.limit = 1000
            query?.findObjectsInBackground(){
                objects, error in
                if let error = error{
                    completion(error)
                    return
                }
                guard let objects = objects else{
                    completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
                    return
                }
                print("objects count " + objects.count.description)
                
                for object in objects{
                    guard let obj = object as? NCMBObject else{
                        fatalError("object Error")
                    }
                    guard let id = obj.intValue(forKey: "id") else{
                        print(obj.object(forKey: "id"))
                        fatalError("id Error")
                    }
                    
                    guard let name = obj.object(forKey: "name") as? String else{
                        print(obj.object(forKey: "name"))
                        fatalError("name Error")
                    }
                    
                    guard let imageNamed = obj.object(forKey: "imageNamed") as? String else{
                        print(obj.object(forKey: "imageNamed"))
                        fatalError("imageNamed Error")
                    }
                    
                    guard let rarity = obj.object(forKey: "rarity") as? String else{
                        print(obj.object(forKey: "rarity"))
                        fatalError("rarity Error")
                    }
                    
                    guard let index = obj.intValue(forKey: "index") else{
                        print(obj.object(forKey: "index"))
                        fatalError("index Error")
                    }
                    guard let hp = obj.intValue(forKey: "hp") else{
                        print(obj.object(forKey: "hp"))
                        fatalError("hp Error")
                    }
                    guard let atk = obj.intValue(forKey: "atk") else{
                        print(obj.object(forKey: "atk"))
                        fatalError("atk Error")
                    }
                    guard let skillNumber = obj.intValue(forKey: "skillNumber")else{
                        print(obj.object(forKey: "skillNumber"))
                        fatalError("skill Error")
                    }
                    guard let skillNumbers = obj.object(forKey: "skillNumbers") as? [Int] else{
                        print(obj.object(forKey: "skillNumbers"))
                        fatalError("skill Error")
                    }
                    
                    //最初と最後の文字が"なのでそれらを消す
                    let newImageNamed = deleteDoubleQuotesFirstAndLast(imageNamed)
                    let newName = deleteDoubleQuotesFirstAndLast(name)
                    let newRarity = deleteDoubleQuotesFirstAndLast(rarity)
                    
                    let card = Card(id: id, name: newName, imageNamed: newImageNamed, rarity: newRarity, index: index, hp: hp, atk: atk, skills: skillNumbers.map{ SkillList.get(id: $0) ?? SkillList.get(id: 0)! })
                    cards.append(card)
                }
                print("completion CardList")
                completion(nil)
            }
        }
    }
    
    
    ///-Warning: デバッグモードでのみ使用
    static func loadPropertyLocal(){
        let path = Bundle.main.path(forResource: "cardInfo", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        let json = try! JSON(data: data)
        
        let result = json.dictionaryValue["results"]
        for obj in result!.arrayValue{
            let id = obj["id"].intValue
            let name = obj["name"].stringValue
            let imageNamed = obj["imageNamed"].stringValue
            let rarity = obj["rarity"].stringValue
            let index = obj["index"].intValue
            let hp = obj["hp"].intValue
            let atk = obj["atk"].intValue
            let skillNumber = obj["skillNumber"].intValue
            let skillNumbers = obj["skillNumbers"].arrayValue.map({ $0.intValue })
            let newImageNamed = deleteDoubleQuotesFirstAndLast(imageNamed)
            let newName = deleteDoubleQuotesFirstAndLast(name)
            let newRarity = deleteDoubleQuotesFirstAndLast(rarity)
            
            let card = Card(id: id, name: newName, imageNamed: newImageNamed, rarity: newRarity, index: index, hp: hp, atk: atk, skills: skillNumbers.map{ SkillList.get(id: $0) ?? SkillList.get(id: 0)! })
            cards.append(card)
        }
    }
    
    ///構成済みデッキクラス
    ///-TODO: いずれ消すこと
    class CardDeck{
        public static var test: Deck{
            return Deck(cards:
                [CardBattle(card: CardList.get(0)!),CardBattle(card: CardList.get(1)!),CardBattle(card: CardList.get(2)!),
                 CardBattle(card: CardList.get(3)!),CardBattle(card: CardList.get(4)!),CardBattle(card: CardList.get(5)!),
                 CardBattle(card: CardList.get(6)!),CardBattle(card: CardList.get(7)!),CardBattle(card: CardList.get(8)!),
                 CardBattle(card: CardList.get(9)!),CardBattle(card: CardList.get(10)!),CardBattle(card: CardList.get(11)!),
                 CardBattle(card: CardList.get(12)!),CardBattle(card: CardList.get(13)!),CardBattle(card: CardList.get(14)!),
                 CardBattle(card: CardList.get(15)!),CardBattle(card: CardList.get(16)!),CardBattle(card: CardList.get(17)!),
                 CardBattle(card: CardList.get(18)!),CardBattle(card: CardList.get(19)!),CardBattle(card: CardList.get(0)!),
                 CardBattle(card: CardList.get(1)!),CardBattle(card: CardList.get(2)!),
                 CardBattle(card: CardList.get(3)!),CardBattle(card: CardList.get(4)!),CardBattle(card: CardList.get(5)!),
                 CardBattle(card: CardList.get(6)!),CardBattle(card: CardList.get(2)!),CardBattle(card: CardList.get(8)!),
                 CardBattle(card: CardList.get(9)!),CardBattle(card: CardList.get(9)!),CardBattle(card: CardList.get(11)!),
                 CardBattle(card: CardList.get(12)!),CardBattle(card: CardList.get(14)!),CardBattle(card: CardList.get(14)!),
                 CardBattle(card: CardList.get(15)!),CardBattle(card: CardList.get(12)!),CardBattle(card: CardList.get(17)!),
                 CardBattle(card: CardList.get(18)!),CardBattle(card: CardList.get(18)!)])
        }
        public static var test2: Deck{
            return Deck(cards:
                [CardBattle(card: CardList.get(20)!),CardBattle(card: CardList.get(21)!),CardBattle(card: CardList.get(22)!),
                 CardBattle(card: CardList.get(23)!),CardBattle(card: CardList.get(24)!),CardBattle(card: CardList.get(25)!),
                 CardBattle(card: CardList.get(26)!),CardBattle(card: CardList.get(27)!),CardBattle(card: CardList.get(28)!),
                 CardBattle(card: CardList.get(29)!),CardBattle(card: CardList.get(30)!),CardBattle(card: CardList.get(31)!),
                 CardBattle(card: CardList.get(32)!),CardBattle(card: CardList.get(33)!),CardBattle(card: CardList.get(34)!),
                 CardBattle(card: CardList.get(35)!),CardBattle(card: CardList.get(36)!),CardBattle(card: CardList.get(37)!),
                 CardBattle(card: CardList.get(38)!),CardBattle(card: CardList.get(39)!)])
        }
    }
}
