//
//  SkillAbilityList.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/15.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
final class SkillAbilityList{
    typealias AmountType = ((_ player: Player) -> (NSNumber))
    typealias ActivateType = ((Player) -> ())
    typealias CheckType = ((Player) -> (Bool))
    final class Activate: NSObject{
        private static let shared = Activate()
        final class ActivateValue: NSObject{
            let value: ActivateType
            init(_ value: @escaping ActivateType) {
                self.value = value
            }
        }
        static let lists: [(_: AmountValue)-> ActivateValue] = [
            activate0,activate1,activate2,activate3,activate4,activate5,activate6,
            activate7,activate8,activate9,activate10,activate11,activate12,activate13,
            activate14,activate15,activate16,activate17,activate18
        ]
        static func perform(_ number: Int, with amount: AmountValue!)-> ActivateType{
            return lists[number](amount).value
        }
        
        
        @objc static func activate0(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ _ in
            }
        }
        
        /// 相手に攻撃する
        @objc static func activate1(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.attack(amount.intValue)
                
            }
        }
        
        
        /// 自傷ダメージを与える
        @objc static func activate2(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.attacked(amount.intValue)
            }
        }
        
        
        /// 自身の体力を回復
        @objc static func activate3(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.heel(amount.intValue)
            }
        }
        
        /// 自身が手札をドロー
        @objc static func activate4(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                 _ = player.drawCards?(amount.intValue)
            }
        }
        
        /// 自身の手札から、現在のテーブルの強さ順で一番弱いカードを捨てる
        @objc static func activate5(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                var cards = player.hand
                cards.sort(by: { player.table.currentCardStrength.compare($0.index, $1.index )})
                
                var tmp: [Card] = []
                for _ in 0..<amount.intValue{
                    if cards.isEmpty{
                        break
                    }
                    let t = cards.filter({ $0.index == cards.first!.index})
                    var card: Card
                    if t.count == 1{
                        card = cards.remove(at: 0)
                    }else{
                        card = t.random
                        cards.remove(at: cards.index(of: card)!)
                    }
                    
                    tmp.append(card)
                }
                player.removeHand(tmp)
            }
        }
        
        /// 自身の手札から、現在のテーブルの強さ順で一番強いカードを捨てる
        /// 複数枚同じ強さのカードがあるならランダムで
        @objc static func activate6(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                var cards = player.hand
                cards.sort(by: { player.table.currentCardStrength.compare($1.index, $0.index )})
                
                var tmp: [Card] = []
                for _ in 0..<amount.intValue{
                    if cards.isEmpty{
                        break
                    }
                    let t = cards.filter({ $0.index == cards.first!.index})
                    var card: Card
                    if t.count == 1{
                        card = cards.remove(at: 0)
                    }else{
                        card = t.random
                        cards.remove(at: cards.index(of: card)!)
                    }
                    
                    tmp.append(card)
                }
                player.removeHand(tmp)
            }
        }
        
        /// 自身の手札からランダムな手札を捨てる
        @objc static func activate7(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                var cards = player.hand
                var tmp: [Card] = []
                for _ in 0..<amount.intValue{
                    if cards.isEmpty{
                        break
                    }
                    
                    let card = cards.remove(at: cards.count.random)
                    tmp.append(card)
                }
                
                player.removeHand(tmp)
            }
        }
        
        /// 自身の手札をすべて捨てる
        @objc static func activate8(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                player.removeAllHand()
            }
        }
        
        /// 自身の攻撃レートを増加させる
        @objc static func activate9(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.changeAtkRate(inc: amount.floatValue)
            }
        }
        
        /// 自身の攻撃レートを減少させる
        @objc static func activate10(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.changeAtkRate(dec: amount.floatValue)
            }
        }
        
        /// 自身の攻撃レートを指標値にする
        @objc static func activate11(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.changeAtkRate(to: amount.floatValue)
            }
        }
        
        /// 相手の攻撃レートを増加させる
        @objc static func activate12(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.enemy.changeAtkRate(inc: amount.floatValue)
            }
        }
        
        /// 相手の攻撃レートを減少させる
        @objc static func activate13(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.enemy.changeAtkRate(dec: amount.floatValue)
            }
        }
        
        /// 相手の攻撃レートを指標値にする
        @objc static func activate14(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                player.enemy.changeAtkRate(to: amount.floatValue)
            }
        }
        
        /// 手札を全て捨て、捨てた枚数*指定レートだけダメージを与える(少数点以下は切り捨て)
        @objc static func activate15(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                let handCount = player.hand.count
                let rate = handCount * amount.floatValue
                activate8(nil).value(player)
                let amount0 = Amount.amount0(rate.i.nsNumber)
                activate1(amount0).value(player)
            }
        }
        
        /// 手札をランダムにすて、捨てたカードの攻撃力の合計値✕指定レートを相手にダメージを与える
        @objc static func activate16(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                var copy = player.hand
                guard let h1 = copy.randomElement() else{ return }
                var cards: [Card] = [h1]
                copy.remove(at: copy.index(of: h1)!)
                if let h2 = copy.randomElement(){ cards.append(h2) }
                player.removeHand(cards)
                
                var atk = cards.reduce(0, { $0 + $1.atk })
                atk = (atk.f * amount.floatValue).i
                player.attack(atk)
            }
        }
        
        /// 相手に相手のHP * amountのダメージで攻撃する
        @objc static func activate17(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                let damage = amount.floatValue * player.enemy.hp.f
                player.attack(damage.i)
                
            }
        }
        
        /// カードを2枚引き、引いたカードの攻撃力の合計値 × amountのダメージを与える
        @objc static func activate18(_ amount: AmountValue!)-> ActivateValue{
            return ActivateValue{ player in
                let amount = amount.value(player)
                guard let cards = player.drawCards?(2) else{
                    return
                }
                let atk = cards.reduce(0, { $0 + $1.atk })
                let damage = amount.floatValue * atk.f
                player.attack(damage.i)
                
            }
        }
    }
    
    final class Check: NSObject{
        final class CheckValue: NSObject{
            let value: CheckType
            init(_ value: @escaping CheckType) {
                self.value = value
            }
        }
        static let lists: [(_: AmountValue)-> CheckValue] = [
            check0,check1,check2,check3,check4,check5,check6,
            check7,check8,check9,check10,check11,check12,check13,
            check14,check15,check16
        ]
        static func perform(_ number: Int, with amount: AmountValue!)-> CheckType{
            return lists[number](amount).value
        }
        
        @objc static func check0(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ _ in
                false
            }
        }
        @objc static func check1(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ _ in
                true
            }
        }
        
        @objc static func check2(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.hand.count >= amount.intValue
            }
        }
        
        @objc static func check3(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.hand.count <= amount.intValue
            }
        }
        
        @objc static func check4(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.hand.count == amount.intValue
            }
        }
        
        @objc static func check5(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.enemy.hand.count >= amount.intValue
            }
        }
        
        @objc static func check6(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.enemy.hand.count <= amount.intValue
            }
        }
        
        @objc static func check7(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.enemy.hand.count == amount.intValue
            }
        }
        
        @objc static func check8(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.allCards.count >= amount.intValue
            }
        }
        
        @objc static func check9(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.allCards.count <= amount.intValue
            }
        }
        
        @objc static func check10(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.allCards.count == amount.intValue
            }
        }
        
        @objc static func check11(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.ownerCards.count >= amount.intValue
            }
        }
        
        @objc static func check12(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.ownerCards.count <= amount.intValue
            }
        }
        
        @objc static func check13(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.ownerCards.count == amount.intValue
            }
        }
        
        @objc static func check14(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.enemyCards.count >= amount.intValue
            }
        }
        
        @objc static func check15(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.enemyCards.count <= amount.intValue
            }
        }
        
        @objc static func check16(_ amount: AmountValue!)-> CheckValue{
            return CheckValue{ player in
                let amount = amount.value(player)
                return player.spot.enemyCards.count == amount.intValue
            }
        }
    }
    
    final class AmountValue: NSObject{
        let value: AmountType
        init(_ value: @escaping AmountType) {
            self.value = value
        }
    }
    
    final class Amount: NSObject{
        static let lists: [()-> AmountValue] = [
            amount1, amount2, amount3, amount4, amount5
        ]
        
        static func perform(_ number: Int)-> AmountValue{
            return lists[number]()
        }
        
        static func amount0(_ amount: NSNumber!)-> AmountValue{
            return AmountValue{ _ in
                amount
            }
        }
        
        @objc static func amount1()-> AmountValue{
            return AmountValue{ player in
                player.hand.count.nsNumber
            }
        }
        
        @objc static func amount2()-> AmountValue{
            return AmountValue{ player in
                player.spot.allCards.count.nsNumber
            }
        }
        
        @objc static func amount3()-> AmountValue{
            return AmountValue{ player in
                player.spot.ownerCards.count.nsNumber
            }
        }
        
        @objc static func amount4()-> AmountValue{
            return AmountValue{ player in
                player.spot.enemyCards.count.nsNumber
            }
        }
        
        @objc static func amount5()-> AmountValue{
            return AmountValue{ player in
                player.enemy.hp.nsNumber
            }
        }
    }
}
