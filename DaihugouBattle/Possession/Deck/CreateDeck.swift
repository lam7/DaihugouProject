//
//  CreateDeck.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/20.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import RxSwift

extension Errors{
    class CreateDeck{
        static let notExistCard = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ作成エラー",
                                                                                  NSLocalizedFailureReasonErrorKey : "そのカードは存在しません"])
        static let overCards = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ作成エラー",
                                                                                  NSLocalizedFailureReasonErrorKey : "これ以上カードを加えることはできません"])
        static let overSamaIndexCards = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ作成エラー",
                                                                                   NSLocalizedFailureReasonErrorKey : "同じインデックスのカードをこれ以上入れることはできません"])
        static let notCorrectSameIndex = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ作成エラー",
                                                                                  NSLocalizedFailureReasonErrorKey : "カード枚数が正しくないものがあります"])
        static let notCorrectCardsNum = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "デッキ作成エラー",
                                                                                            NSLocalizedFailureReasonErrorKey : "デッキの枚数が正しくないです"])
    }
}

class CreateDeck{
    private var possessionCardsVar: Variable<CardCount> = Variable([:])
    private var deckCardsVar: Variable<[Card]> = Variable([])
    
    var deckCardsValue: [Card]{
        return deckCardsVar.value
    }
    var possessionCardsValue: CardCount{
        return possessionCardsVar.value
    }
    
    var originalPossessionCards: [Card]{
        return possessionCardsVar.value.map{ $0.key }
    }
    
    var deckCards: Observable<[Card]>{
        return deckCardsVar.asObservable()
    }
    var possessionCards: Observable<CardCount>{
        return possessionCardsVar.asObservable()
    }
    var deck: Deck?
    
    init(deck: Deck?){
        self.deck = deck
    }
    ///所持カードをセットする
    final func set(possessionCards: CardCount){
        if let deck = self.deck{
            let cards = deck.notExistDeckCards(in: possessionCards)
            var deckCards = convertCardCount(deck.cards)
            if !cards.isEmpty{
                deckCards -= cards
            }
            deckCardsVar.value = convertCardArray(deckCards)
            
            var p = possessionCards
            p -= deckCards
            cards.forEach{
                if p[$0.key] == nil{
                    p[$0.key] = 0
                }
            }
            possessionCardsVar.value = p
        }else{
            possessionCardsVar.value = possessionCards
        }
    }
    
    ///デッキにカードを追加する。追加されたカードは所持カードから１枚減る。
    ///但し、所持カードに指定のカードがない場合追加できない。
    ///- errors: なにかしらのエラーが発生した場合NSErrorを返す。localizedDescriptionにタイトルをlocalizedFailureReasonにエラーが起きたろ理由を示す。
    final func append(_ card: Card) throws{
        try checkAppend(card, possessionCards: possessionCardsVar.value, deckCards: convertCardCount(deckCardsVar.value))
        if possessionCardsVar.value[card] != nil{
            possessionCardsVar.value[card]! -= 1
            var cards = deckCardsVar.value + card
            cards.sort(bys: [CardsSort.indexSort, CardsSort.idSort])
            deckCardsVar.value = cards
        }
    }

    ///デッキからにカードを削除する。削除されたカードは所持カードに１枚追加する。
    ///但し、所持カードに指定のカードがない場合追加できない。
    ///- errors: なにかしらのエラーが発生した場合NSErrorを返す。localizedDescriptionにタイトルをlocalizedFailureReasonにエラーが起きたろ理由を示す。
    final func remove(_ card: Card) throws{
        try checkRemove(card, possessionCards: possessionCardsVar.value, deckCards: convertCardCount(deckCardsVar.value))
        if let i = deckCardsVar.value.index(of: card){
            deckCardsVar.value.remove(at: i)
            if possessionCardsVar.value[card] == nil{
               possessionCardsVar.value[card] = 1
            }else{
               possessionCardsVar.value[card]! += 1
            }
        }
    }

    ///デッキを作成
    final func create(_ name: String = "")-> Deck{
        if self.deck == nil{
            return Deck(cards: deckCardsVar.value, name: name)
        }else{
            return DeckRelated(deck: deck!, cards: deckCardsVar.value)
        }
    }
    
    final func canCreate()throws{
        try checkCreate(possessionCardsVar.value, deckCards: convertCardCount(deckCardsVar.value))
    }
    
    func checkAppend(_ card: Card, possessionCards: CardCount, deckCards: CardCount) throws{
        if possessionCards[card] == nil{
            throw Errors.CreateDeck.notExistCard
        }
    }
    
    func checkRemove(_ card: Card, possessionCards: CardCount, deckCards: CardCount) throws{
        if deckCards[card] == nil{
            throw Errors.CreateDeck.notExistCard
        }
    }
    
    func checkCreate(_ possessionCards: CardCount, deckCards: CardCount) throws{
        
    }
}

class CreateStandartDeck: CreateDeck{
    ///デッキにカードを追加するとき、デッキに入れられる最大枚数
    let MaxDeckCardsCountInAppend = 50
    ///デッキにカードを追加するとき、同じインデックスがデッキに入れられる最大枚数
    let MaxSamaIndexCardsCountInAppend = 10
    ///デッキ完成時のそれぞれのインデックスの最大枚数
    let MaxSameIndexCountInComplete = 5
    
    
    
    override func checkAppend(_ card: Card, possessionCards: CardCount, deckCards: CardCount) throws {
        try super.checkAppend(card, possessionCards: possessionCards, deckCards: deckCards)
        
        if deckCards.reduce(0, { $0 + $1.value }) >= MaxDeckCardsCountInAppend{
            throw Errors.CreateDeck.overCards
        }
        
        let count = deckCards[card] ?? 0 + 1
        if count >= MaxSamaIndexCardsCountInAppend{
            throw Errors.CreateDeck.overSamaIndexCards
        }
    }
    
    override func checkRemove(_ card: Card, possessionCards: CardCount, deckCards: CardCount) throws {
        if deckCards[card] == nil{
            throw Errors.CreateDeck.notExistCard
        }
        try super.checkRemove(card, possessionCards: possessionCards, deckCards: deckCards)
    }
    
    override func checkCreate(_ possessionCards: CardCount, deckCards: CardCount) throws {
        try super.checkCreate(possessionCards, deckCards: deckCards)
        if deckCards.reduce(0, { $0 + $1.value }) != StandartDeckCardsNum{ throw Errors.CreateDeck.notCorrectCardsNum }
        let counts = deckCards.filter{ $0.value > MaxSameIndexCountInComplete }
        if !counts.isEmpty{
            throw Errors.CreateDeck.notCorrectSameIndex
        }
    }
}

//typealias CreateDeckAppendErrorType = ((_ card: Card, _ possessionCards: [Card], _ deckCards: [Card]) throws -> ())
//typealias CreateDeckDeckErrorType = ((_ deck: [Card]) throws -> ())
// //デッキ作成Protocol
//protocol CreateDeck: class{
//
//    /// デッキ作成時にデッキに入れることが出来るカードの最大容量
//    var CountOfLimit: Int{get}
//    /// デッキ枚数
//    var CountAtCompletion: Int{get}
//
//    ///　同じ数字をデッキに何枚まで入れられるか
//    /// キー：　インデックス、　バリュー：　その数字の許容枚数
//    var CountOfSameIndex: [Int : Int]{get}
//    /// デッキのカード配列
//    var deckCards: CardCount{get}
//
//    var possessionCards: CardCount{get}
//    /// デッキにカードを追加
//    ///
//    /// - Parameter card: 追加するカード
//    /// - Throws: これ以上カードを追加できないときにCrossedDeckError.OverCountOfLimitを返す
//    func append(_ card: Card) throws
//    /// デッキからカードを削除
//    ///
//    /// - Parameter at: deckCards[at]のカードを削除する
//    /// - Throws: 不明な位置にatがあるならCrossedDeckError.OutOfRangeを返す
//    func remove(_ card: Card) throws
//
//
//    /// デッキが作成可能かチェックする
//    func checkCreate()-> Error?
//    /// デッキを作成する
//    /// デッキをチェックしエラーが何もないならUserInfo.shared.append(deck)を呼び出す
//    /// - Parameter completion: デッキ追加完了後の処理
//    func create(_ completion: @escaping (_ error: Error?) -> ())
//}
//
//enum CreateStandartDeckError: String, LocalizedError{
//    case InsufficientNumberOfCards = "カードの枚数が足りていません"
//    case ExceedNumberOfCards = "カードの枚数が多すぎます"
//    case OverCountOfLimit = "これ以上カード追加出来ません"
//    case OverCountOfIndexs = "その数字をそれ以上追加出来ません"
//    case OutOfRange = "そのカードを削除することは出来ません"
//    case NotExist = "そのカードは存在しません"
//
//    var localizedDescription: String {
//        return NSLocalizedString(self.rawValue, comment: "")
//    }
//}
//
//class CreateStandartDeck: CreateDeck{
//    var CountOfLimit: Int{
//        return 40
//    }
//
//    var CountAtCompletion: Int{
//        return 20
//    }
//
//    var CountOfSameIndex: [Int : Int]{
//        return [1 : 2, 2 : 2, 3 : 2, 4 : 2, 5 : 2, 6 : 2, 7 : 2, 8 : 2, 9 : 2, 10 : 2]
//    }
//
//    private var deckCards_: [Card]
//    private(set) var possessionCards: CardCount
//    var deckCards: CardCount{
//        var t: CardCount = []
//        var collection = deckCards_.collection
//        collection.sort(by: { $0.first!.id < $1.first!.id })
//        for c in collection{
//            t.append((c.first!, c.count))
//        }
//        return t
//    }
//
//    init(cards: CardCount){
//        deckCards_ = []
//        possessionCards = cards
//    }
//
//    func append(_ card: Card) throws{
//        var index = -1
//        for i in 0..<possessionCards_.count{
//            if possessionCards_[i].card == card && possessionCards_[i].count > 0{
//                index = i
//                break
//            }
//        }
//        if index == -1{
//            throw CreateStandartDeckError.NotExist
//        }
//        if deckCards_.count >= CountOfLimit{
//            throw CreateStandartDeckError.OverCountOfLimit
//        }
//
//        let indexCount = deckCards_.filter({ $0.index == card.index }).count
//        if indexCount == CountOfSameIndex[card.index]!{
//            throw CreateStandartDeckError.OverCountOfIndexs
//        }
//        let c = possessionCards_[index].card
//        possessionCards_[index] = (card: c, count: possessionCards_[index].count - 1)
//        deckCards_.append(c)
//    }
//
//    func remove(_ card: Card) throws{
//        var index = -1
//        for i in 0..<deckCards_.count{
//            if deckCards_[i] == card{
//                index = i
//                break
//            }
//        }
//        if index == -1{
//              throw CreateStandartDeckError.OutOfRange
//        }
//
//        let c = deckCards_.remove(at: index)
//        for i in 0..<possessionCards_.count{
//            if possessionCards_[i].card == card{
//                possessionCards_[i] = (card: possessionCards_[i].card, count: possessionCards_[i].count + 1)
//                return
//            }
//        }
//        possessionCards_.append((card: c, count: 1))
////        possessionCards_.append(c)
//    }
//
//    func checkCreate()-> Error?{
//        let count = CountAtCompletion
//        if deckCards_.count > count{
//            return CreateStandartDeckError.ExceedNumberOfCards
//        }
//        if deckCards_.count < count{
//            return CreateStandartDeckError.InsufficientNumberOfCards
//        }
//        return nil
//    }
//
//    func create(_ completion: @escaping (_ error: Error?) -> ()){
//        if let error = checkCreate(){
//            completion(error)
//            return
//        }
//        //TODO: デッキ名前決定画面ができたらこの処理を変更する
//        let c = UserInfo.shared.deckIdsValue.count
//        UserInfo.shared.append(deck: deckCards_, name: "デッキ\(c+1)", completion: completion)
//
//    }
//}
