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
    
    /// デッキに指定のカードがあるかどうか確認する
    ///
    /// - Parameter possessionCards: あるかどうか確認するカード
    /// - Returns: デッキになかったカード
    private func notExistDeckCards(in possessionCards: CardCount, deck: Deck)-> CardCount{
        var possessionCards = possessionCards
        var notExistCards: CardCount = [:]
        
        for card in deck.cards.reversed(){
            if possessionCards[card] != nil && possessionCards[card]! >= 1{
                possessionCards -= card
            }else{
                notExistCards += card
            }
        }
        return notExistCards
    }

    ///所持カードをセットする
    final func set(possessionCards: CardCount){
        if let deck = self.deck{
            let cards = notExistDeckCards(in: possessionCards, deck: deck)
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
        if let i = deckCardsVar.value.firstIndex(of: card){
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
            let deck = DeckRelated(cards: deckCardsVar.value)
            deck.name = name
            return deck
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
        
        if possessionCards[card] == nil || possessionCards[card] == 0{
            throw Errors.CreateDeck.notExistCard
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
