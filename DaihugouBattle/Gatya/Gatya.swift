//
//  Gatya.swift
//  Daihugou
//
//  Created by Main on 2017/06/05.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import NCMB

/// ガチャの情報を持つ構造帯
struct GatyaType{
    /// 確率
    var probability: Probability
    /// 一回ガチャを引くのに消費する金額
    var consume: Consume
    /// ガチャから排出されるカードid一覧
    var availableCardId: [Int]
    /// Pickerで表示される画像
    var imagePath: String
    /// ガチャの名前
    var name: String
    /// ガチャ識別id
    var id: Int
    
    
    /// UR, SR, R, Nが出る確率
    struct Probability{
        var UR, SR, R, N: Float
    }
    
    /// ゴールド，クリスタル，チケット消費量
    struct Consume{
        var gold, crystal, ticket: Int
    }
}

enum GatyaError: LocalizedError{
    case notEnough(GatyaBuyType)
    case failureNetwork
    var localizedDescription: String{
        switch self {
        case .failureNetwork:
            return "通信エラー"
        case .notEnough(let buyType):
            return buyType.rawValue + "の枚数が十分でない"
        }
    }
}
///ガチャの購入方法
enum GatyaBuyType: String{
    case gold = "gold"
    case crystal = "crystal"
    case ticket = "ticket"
}

class Gatya{
    static var gatyaTypes: [GatyaType] = []
    private(set) var buyType: GatyaBuyType
    private(set) var rollTimes: Int
    private(set) var gatyaType: GatyaType
    
    init(buyType: GatyaBuyType, rollTimes: Int, gatyaType: GatyaType){
        self.buyType = buyType
        self.rollTimes = rollTimes
        self.gatyaType = gatyaType
    }
    
    class func getTypes(_ completion: @escaping (_ types: [GatyaType], _ error: Error?) -> ()){
        fatalError("Please override this method")
    }
    
    func roll(_ completion: @escaping(_ cards: [Card], _ error: Error?) -> ()){
        fatalError("Please override this method")
    }
    
    func canRoll()-> Bool{
        switch buyType {
        case .gold:
            return UserInfo.shared.goldValue >= gatyaType.consume.gold * rollTimes
        case .crystal:
            return UserInfo.shared.crystalValue >= gatyaType.consume.crystal * rollTimes
        case .ticket:
            return UserInfo.shared.ticketValue >= gatyaType.consume.ticket * rollTimes
        }
    }
    
    fileprivate func reduce(_ completion: @escaping(_ error: Error?) -> ()){
        switch buyType {
        case .gold:
            let amount = gatyaType.consume.gold * rollTimes
            UserInfo.shared.reduce(gold: amount, completion: completion)
        case .crystal:
            let amount = gatyaType.consume.crystal * rollTimes
            UserInfo.shared.reduce(crystal: amount, completion: completion)
        case .ticket:
            let amount = gatyaType.consume.ticket * rollTimes
            UserInfo.shared.reduce(ticket: amount, completion: completion)
        }
    }
}
/// サーバーでガチャを引くクラス
class GatyaServer: Gatya{
    /// サーバーからガチャの情報を取ってくる
    /// 最大取ってくるのは10件まで．これを超えるにはlimitを変更する必要がある
    /// - Parameter completion: 完了後の処理
    override class func getTypes(_ completion: @escaping (_ types: [GatyaType], _ error: Error?) -> ()){
        let gatyaType = NCMBQuery(className: "gatyaType")
        gatyaType?.limit = 10
        gatyaType?.findObjectsInBackground({
            objects, error in
            if let error = error{
                completion([], error)
                return
            }

            guard let objects = objects else{
                completion([], NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
                return
            }

            var types: [GatyaType] = []
            for object in objects{
                guard let obj = object as? NCMBObject else{
                    fatalError("Download-getImageInfo object Error")
                    continue
                }
                let UR              = obj.floatValue(forKey: "UR")!
                let SR              = obj.floatValue(forKey: "SR")!
                let R               = obj.floatValue(forKey: "R")!
                let N               = obj.floatValue(forKey: "N")!
                let gold            = obj.intValue(forKey: "gold")!
                let crystal         = obj.intValue(forKey: "crystal")!
                let ticket          = obj.intValue(forKey: "ticket")!
                let availableCardId = obj.object(forKey: "availableCard") as! [Int]
                let imagePath       = deleteDoubleQuotesFirstAndLast(obj.object(forKey: "imagePath") as! String)
                let name            = deleteDoubleQuotesFirstAndLast(obj.object(forKey: "name") as! String)
                let id              = obj.intValue(forKey: "id")!
                
                let gatyaType = GatyaType(probability: GatyaType.Probability(UR: UR, SR: SR, R: R, N: N), consume: GatyaType.Consume(gold: gold, crystal: crystal, ticket: ticket), availableCardId: availableCardId, imagePath: imagePath, name: name, id: id)
                types.append(gatyaType)
            }
            self.gatyaTypes = types
            completion(types, nil)
        })
        
    }
    
    /// サーバーでガチャを回す
    /// 先にガチャを回しその後、金を消費する
    /// - Parameters:
    ///   - gatyaId: 回すガチャのid
    ///   - times: 回す回数
    ///   - consumeType: 消費する種類．"gold", "crystal", "ticket"のいずれか
    ///   - completion: 完了後の処理
    override func roll(_ completion: @escaping(_ cards: [Card], _ error: Error?) -> ()){
        guard let gatya = NCMBScript.init(name: "Gatya.js", method: NCMBScriptRequestMethod.executeWithGetMethod) else{
            completion([], NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
            return
        }
        guard canRoll() else {
            completion([], GatyaError.notEnough(buyType))
            return
        }
        
        gatya.execute(nil, headers: nil, queries: ["user": UserLogin.objectIdUserInfo, "item": gatyaType.id, "type": buyType.rawValue, "times": rollTimes.description], with: {
            data, error in
            if let error = error{
                completion([], error)
                return
            }
            
            let text = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            let ids: [Int] = text!.components(separatedBy: ",").map({ Int($0)! })
            let cards: [Card] = ids.map({ CardList.get(id: $0)! })
            completion(cards, nil)
        })
    }
    
   
//    func roll(_ gatyaId: Int, times: Int, consumeType: String, completion: @escaping (_ cards: [Card], _ error: Error?) -> ()){
//        guard let gatya = NCMBScript.init(name: "Gatya.js", method: NCMBScriptRequestMethod.executeWithGetMethod) else{
//            completion([], NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
//            return
//        }
//
//        gatya.execute(nil, headers: nil, queries: ["user": UserLogin.objectIdUserInfo, "item": gatyaId.description, "type": consumeType, "times": times.description], with: {
//            data, error in
//            if let error = error{
//                completion([], error)
//                return
//            }
//
//            let text = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//            let ids: [Int] = text!.components(separatedBy: ",").map({ Int($0)! })
//            let cards: [Card] = ids.map({ CardList.get(id: $0)! })
//            completion(cards, nil)
//        })
//    }
}

class GatyaServerAndLocal: GatyaServer{
    override class func getTypes(_ completion: @escaping ([GatyaType], Error?) -> ()) {
        super.getTypes{
            types, error in
            if let error = error{
                completion(types, error)
                return
            }
            
            // ローカルで引くガチャの情報は
            // サーバーから取ってきたid * -1でidを指定しておく
            // 名前はトップに"L"をつける
            var localTypes = types
            localTypes.forEach({
                type in
                var local = type
                local.name = "L" + type.name
                local.id   = type.id * -1
                localTypes.append(local)
            })
            self.gatyaTypes = localTypes
            completion(localTypes, nil)
        }
    }
    
    override func roll(_ completion: @escaping (_ cards: [Card], _ error: Error?) -> ()){
        print("rolling")
        if gatyaType.id >= 0{
            super.roll(completion)
            return
        }
        
        let cards = drawCard(rollTimes, gatyaType: gatyaType)
        print("append")
        /// 得たカードをサーバー側に追加
        UserInfo.shared.append(cards: cards){
            appendError in
            print("appendStart")
            let start = Date()
            if let appendError = appendError{
                completion([], appendError)
                return
            }
            self.reduce(){
                error in
                let elapsed = Date().timeIntervalSince(start)
                print(elapsed)
                print("appendEnd")
                if let error  = error{
                    completion([], error)
                }
                completion(cards, nil)
            }
        }
        
    }
    
    
    /// 指定のガチャからランダムなカードをそれぞれの確率で返す
    /// UR, SR, R, Nのどれかが決まったなら，1 / (そのレアリティで手に入るカードの枚数)　でランダムに一枚のカードが選ばれる
    /// - Parameter gatyaType: ガチャの種類
    /// - Returns: ランダムなカード
    private func randomCard(_ gatyaType: GatyaType)-> Card{
        let rarity = randomRarity(gatyaType)
        let availableCards = gatyaType.availableCardId.map({ CardList.get(id: $0)! })
        let cards = availableCards.filter{ $0.rarity == rarity }
        let card = cards.random
        return CardList.get(id: card.id)!
    }
    
    
    /// UR, SR, R, Nのいずれかをそれぞれの確率で返す
    ///
    /// - Parameter gatyaType: ガチャの種類
    /// - Returns: UR, SR, R, N
    private func randomRarity(_ gatyaType: GatyaType)-> CardRarity{
        // 0 ~ 1の乱数
        let rand = 1.0.f.random
        let probabilities = gatyaType.probability
        let sumOfUR = probabilities.UR
        let sumOfSR = sumOfUR + probabilities.SR
        let sumOfR  = sumOfSR + probabilities.R
        let sumOfN  = sumOfR  + probabilities.N
        switch rand {
        case let r where r < sumOfUR:
            return .UR
        case let r where r < sumOfSR:
            return .SR
        case let r where r < sumOfR:
            return .R
        case let r where r < sumOfN:
            return .N
        default:
            fatalError("GatyaRandomNumberIsFailed")
        }
    }
    
    /// ガチャからカードを一枚得る
    /// ユーザーに所持カードを加える
    ///
    /// - Returns: ガチャから得たカード
    private func drawCard(_ times: Int, gatyaType: GatyaType)-> [Card]{
        var getCard: [Card] = []
        
        for _ in 0 ..< times * 8{
            let card = randomCard(gatyaType)
            getCard.append(card)
        }
        return getCard
    }
}
