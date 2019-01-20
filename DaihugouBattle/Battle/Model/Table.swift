//
//  Table.swift
//  Daihugou
//
//  Created by Main on 2017/05/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

protocol TableDelegate: class{
    func changeCardStrength(_ cardStrength: CardStrength)
    func changeSpotStatus(_ status: SpotStatus)
}

enum SpotStatus{
    case empty
    case single
    case pair(Int)
    case stairs(Int)
}

///バトルルール情報を管理するクラス
class Table: NSCopying{
    ///現在のカードの強さ順
    private(set) var currentCardStrength: CardStrength
    /// 手札最大枚数
    fileprivate(set) var maxHandCount = 9
    ///現在の場のステータス(ペア出し、シングル出しetc)
    fileprivate(set) var spotStatus: SpotStatus
    
    /// ペアにするための最小カード枚数
    fileprivate(set) var minSheetsPair: Int = 2
    
    /// 階段にするための最小カード枚数
    fileprivate(set) var minSheetsStair: Int = 3
    
    
    public weak var delegate: TableDelegate?
    
    init() {
        currentCardStrength = .normal
        spotStatus = .empty
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let table = Table()
        table.currentCardStrength = self.currentCardStrength
        table.maxHandCount = self.maxHandCount
        table.spotStatus = self.spotStatus
        table.minSheetsPair = self.minSheetsPair
        table.minSheetsStair = self.minSheetsStair
        return table
    }
    
    /// カードの強さを比べる
    ///
    /// カードの強さ順はcurrentCardStrengthを参照する
    ///
    /// - Parameters:
    ///   - compareCard: 比べるカード
    ///   - comparedCard: 比べられるカード
    /// - Returns: ```compareCard.index > comparedCard.inedx```
    func checkCardStrength(_ compareCard: Card, comparedCard: Card)-> Bool{
        return currentCardStrength.compare(compareCard.index, comparedCard.index)
    }
    
    /// ペアでのカードの強さを比べる
    func checkPairCardsStrength(_ compareCards: [Card], comparedCards: [Card])-> Bool{
        if compareCards.count != comparedCards.count{ return false }
        return checkCardStrength(compareCards.first!, comparedCard: comparedCards.first!)
    }
    
    
    /// 階段は一番小さいカードの数字どうしでチェックする．
    /// 例) 456なら567以上ならok
    func checkStairsCardStrength(_ compareCards: [Card], comparedCards: [Card])-> Bool{
        if compareCards.count != comparedCards.count{ return false }
        let sort1 = compareCards.sorted(){
            $0.index < $1.index
        }
        
        let sort2 = comparedCards.sorted(){
            $0.index < $1.index
        }
        
        guard let card1 = sort1.first,
            let card2 = sort2.first else{
                return false
        }
        return checkCardStrength(card1, comparedCard: card2)
        
    }
    
    /// カード枚数が一枚かどうか調べる．
    /// - Parameter cards: カード
    /// - Returns:　シングルかどうか
    func checkIsSingle(_ cards: [Card])-> Bool{
        return cards.count == 1
    }
    /// カードの全てのインデックスが同じかどうか調べる．
    ///
    /// - Parameter cards: カード
    /// - Returns: ペアになっているかどうか
    func checkIsPair(_ cards: [Card])-> Bool{
        guard let first = cards.first else{
            return false
        }
        for card in cards{
            if card.index != first.index && card.index != 0{
                return false
            }
        }
        return true
    }
    
    
    /// カードが階段になっているかどうかチェックする．
    /// カードのインデックスが連番になっているかどうか．
    ///
    /// - Parameter cards: カード
    /// - Returns: 階段になっているかどうか
    func checkIsStairs(_ cards: [Card])-> Bool{
        let sort = cards.sorted(){
            $0.index < $1.index
        }
        guard let first = sort.first else{
            return false
        }
        
        for i in 1 ..< sort.count{
            if sort[i].index != first.index + i{
                return false
            }
        }
        return true
    }
    
    func checkIsCurrentSpotStatus(_ cards: [Card])-> Bool{
        if cards.isEmpty{ return false }
        switch spotStatus{
        case .empty:
            let single = checkIsSingle(cards)
            let pair = checkIsPair(cards) && cards.count >= minSheetsPair
            let stair = checkIsStairs(cards) && cards.count >= minSheetsStair
            if single || pair || stair{
                return true
            }
            return false
        case .single:
            return checkIsSingle(cards)
        case .pair(let count):
            return checkIsPair(cards) && cards.count == count
        case .stairs(let count):
            return checkIsStairs(cards) && cards.count == count
        }
    }
    
    
    /// カードをスポットに出せるかチェックする
    ///
    /// - Parameters:
    ///   - cards: 出すカード
    ///   - spotCards: スポットの全カード
    /// - Returns: 出せるかどうか
    func canPutDown(_ cards: [Card], spotCards: [Card])-> Bool{
        guard checkIsCurrentSpotStatus(cards) else { print("NotCurrentSpot"); return false }
        
        switch spotStatus{
        case .empty: return true
        case .single:
            let c = spotCards.last!
            return checkCardStrength(cards.first!, comparedCard: c)
        case .pair(let count):
            let c = spotCards[(spotCards.count - count) ..< spotCards.count].map{ $0 }
            return checkPairCardsStrength(cards, comparedCards: c)
        case .stairs(let count):
            let c = spotCards[(spotCards.count - count) ..< spotCards.count].map{ $0 }
            return checkStairsCardStrength(cards, comparedCards: c)
        }
    }
    
    func classify(_ cards: [Card])-> (single: [[Card]], pair: [[Card]], stair: [[Card]]){
        let S = 2 ** cards.count
        var single: [[Card]] = []
        var pair: [[Card]] = []
        var stair: [[Card]] = []
        for s in 0..<S{
            var c: [Card] = []
            for i in 0..<cards.count{
                if s & (1 << i) == (1 << i){
                    c.append(cards[i])
                }
            }
            if checkIsSingle(c){ single.append(c) }
            if checkIsPair(c){ pair.append(c) }
            if checkIsStairs(c){ stair.append(c) }
        }
        return (single: single, pair: pair, stair: stair)
    }
    /// スポットの状態を変える
    private func changeSpotStatus(to: SpotStatus){
        spotStatus = to
        delegate?.changeSpotStatus(to)
    }
    
    /// スポットの状態をカードによって変える
    func changeSpotStatus(by cards: [Card]){
        if cards.isEmpty{
            changeSpotStatus(to: .empty)
        }else if checkIsSingle(cards){
            changeSpotStatus(to: .single)
        }else if checkIsPair(cards){
            changeSpotStatus(to: .pair(cards.count))
        }else if checkIsStairs(cards){
            changeSpotStatus(to: .stairs(cards.count))
        }
    }
    
    /// カードの強さ順を変える
    ///
    /// - Parameter cardStrength: CardDefine.CardStrengthListを使う
    func changeCurrentCardStrength(_ cardStrength: CardStrength){
        currentCardStrength = cardStrength
        delegate?.changeCardStrength(cardStrength)
    }
    
    func calcAtk(_ cards: [Card], rate: Float)-> Int{
        return Int(cards.reduce(0, { $0 + $1.atk }) * rate)
    }
}





//class Table{
//    ///現在のカードの強さ順
//    private(set) var currentCardStrength: CardStrength
//    /// 手札最大枚数
//    fileprivate (set) var maxHandCount = 9
//    ///山札
//    private(set) var spot: Spot
//    ///山札の一番上
//    private var spotLast: Card?{
//        return self.spot.allCards.last
//    }
//
//    private var fromLastToEnd: ((_: [Card], _: Int) -> [Card]) = {
//        (cards: [Card], count: Int) -> [Card] in
//
//        var tmp: [Card] = []
//
//        if cards.count < count{
//            return []
//        }
//
//        for i in cards.count - count ..< cards.count{
//            tmp.append(cards[i])
//        }
//        return tmp
//    }
//
//    ///現在の場のステータス(ペア出し、シングル出しetc)
//    private (set) var spotStatus: SpotStatus
//
//    /// ペアにするための最小カード枚数
//    private(set) var minSheetsPair: Int = 2
//
//    /// 階段にするための最小カード枚数
//    private(set) var minSheetsStair: Int = 3
//
//
//    public weak var delegate: TableDelegate?
//
//    public weak var battleField: BattleField!
//
//    public var owner: Player!{
//        return battleField.owner
//    }
//
//    public var enemy: Player!{
//        return battleField.enemy
//    }
//
//    ///normalCardStrengthでスタート
//    ///
//    ///全てのspot,cameteryを空にする
//    init() {
//        currentCardStrength = .normal
//        spot = Spot()
//        spotStatus = .empty
//    }
//
//    /// カードの強さを比べる
//    ///
//    /// カードの強さ順はcurrentCardStrengthを参照する
//    ///
//    /// - Parameters:
//    ///   - compareCard: 比べるカード
//    ///   - comparedCard: 比べられるカード
//    /// - Returns: ```compareCard.index > comparedCard.inedx```
//    func checkCardStrength(_ compareCard: Card, comparedCard: Card)-> Bool{
//        return currentCardStrength.compare(compareCard.index, comparedCard.index)
//    }
//
//    /// ペアでのカードの強さを比べる
//    func checkPairCardsStrength(_ compareCards: [Card], comparedCards: [Card])-> Bool{
//        if compareCards.count != comparedCards.count{ return false }
//        return checkCardStrength(compareCards.first!, comparedCard: comparedCards.first!)
//    }
//
//
//    /// 階段は一番小さいカードの数字どうしでチェックする．
//    /// 例) 456なら567以上ならok
//    func checkStairsCardStrength(_ compareCards: [Card], comparedCards: [Card])-> Bool{
//        if compareCards.count != comparedCards.count{ return false }
//        let sort1 = compareCards.sorted(){
//            $0.index < $1.index
//        }
//
//        let sort2 = comparedCards.sorted(){
//            $0.index < $1.index
//        }
//
//        guard let card1 = sort1.first,
//            let card2 = sort2.first else{
//                return false
//        }
//        return checkCardStrength(card1, comparedCard: card2)
//
//    }
//
//    /// カード枚数が一枚かどうか調べる．
//    /// - Parameter cards: カード
//    /// - Returns:　シングルかどうか
//    func checkIsSingle(_ cards: [Card])-> Bool{
//        return cards.count == 1
//    }
//    /// カードの全てのインデックスが同じかどうか調べる．
//    ///
//    /// - Parameter cards: カード
//    /// - Returns: ペアになっているかどうか
//    func checkIsPair(_ cards: [Card])-> Bool{
//        guard let first = cards.first else{
//            return false
//        }
//        for card in cards{
//            if card.index != first.index && card.index != 0{
//                return false
//            }
//        }
//        return true
//    }
//
//
//    /// カードが階段になっているかどうかチェックする．
//    /// カードのインデックスが連番になっているかどうか．
//    ///
//    /// - Parameter cards: カード
//    /// - Returns: 階段になっているかどうか
//    func checkIsStairs(_ cards: [Card])-> Bool{
//        guard let first = cards.first else{
//            return false
//        }
//        let sort = cards.sorted(){
//            $0.index < $1.index
//        }
//
//        for i in 1 ..< sort.count{
//            if sort[i].index != first.index + i{
//                return false
//            }
//        }
//        return true
//    }
//
//    /// 山札にカードを出す
//    /// - important: カードの強さ判定は行わずどんなカードでも出せる様になっている
//    /// - Parameter card: 出すカード
//    func putDown(_ cards: [Card], isOwner: Bool){
//        changeSpotStatus(by: cards)
//        spot.append(cards, isOwner: isOwner)
//        delegate?.putDown(cards, isOwner: isOwner)
//        if cards.count >= 4{
//            if currentCardStrength == .revolution{
//                changeCurrentCardStrength(.normal)
//            }else if currentCardStrength == .normal{
//                changeCurrentCardStrength(.revolution)
//            }
//
//        }
//    }
//
//
//    /// カードが出せるかどうか調べる
//    ///
//    /// 山札になにもないか，山札の一番上のカードより強いか調べる
//    /// - Parameter card: 調べるカード
//    /// - Returns: ``` spotLast != nil || checkCardStrength(compareCard: card, comparedCard: spotLast!)```
//    func checkPutDown(_ cards: [Card])-> Bool {
//        if cards.isEmpty{ return false }
//        switch spotStatus {
//        case .empty:
//            let single = checkIsSingle(cards)
//            let pair = checkIsPair(cards) && cards.count >= minSheetsPair
//            let stair = checkIsStairs(cards) && cards.count >= minSheetsStair
//            if single || pair || stair{
//                return true
//            }
//            return false
//        case .single:
//            let single = checkIsSingle(cards)
//            if single{
//                return checkCardStrength(cards.first!, comparedCard: spotLast!)
//            }
//            return false
//        case .pair(let count):
//            let pair = checkIsPair(cards) && cards.count == count
//            if pair{
//                return checkPairCardsStrength(cards, comparedCards: fromLastToEnd(spot.allCards, count))
//            }
//            return false
//
//        case .stairs(let count):
//            let stair = checkIsStairs(cards) && cards.count == count
//            if stair{
//                return checkStairsCardStrength(cards, comparedCards: fromLastToEnd(spot.allCards, count))
//            }
//            return false
//        }
//    }
//
//
//
//    /// スポットの状態を変える
//    private func changeSpotStatus(to: SpotStatus){
//        spotStatus = to
//    }
//
//    /// スポットの状態をカードによって変える
//    private func changeSpotStatus(by cards: [Card]){
//        if checkIsSingle(cards){
//            changeSpotStatus(to: .single)
//        }else if checkIsPair(cards){
//            changeSpotStatus(to: .pair(cards.count))
//        }else if checkIsStairs(cards){
//            changeSpotStatus(to: .stairs(cards.count))
//        }
//    }
//
//
//    /// 山札を墓地に流す
//    func passingCameteryFromSpot(){
//        delegate?.passingCamesteryFromSpot(spot.allCards)
//        spotStatus = .empty
//        spot.cardsWithIdentifer.forEach({
//            if $0.isOwner{
//                owner.passingCametery([$0.card])
//            }else{
//                enemy.passingCametery([$0.card])
//            }
//        })
//        spot.removeAll()
//    }
//
//
//    /// カードの強さ順を変える
//    ///
//    /// - Parameter cardStrength: CardDefine.CardStrengthListを使う
//    func changeCurrentCardStrength(_ cardStrength: CardStrength){
//        currentCardStrength = cardStrength
//        delegate?.changeCardStrength(cardStrength)
//    }
//}
//
