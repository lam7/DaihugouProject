//
//  Skill.swift
//  Daihugou
//
//  Created by Main on 2017/05/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import NCMB
import SwiftyJSON

class Skill{
    private(set) var checks: [SkillAbilityList.CheckType]
    private(set) var activates: [SkillAbilityList.ActivateType]
    private static var skills:[String : Skill] = [:]
    
    fileprivate(set) var description: String = ""
    fileprivate(set) var activateType: ActivateType = .fanfare
    
    enum ActivateType: String{
        case fanfare, lastword, ownerTurnStart, ownerTurnEnd, enemyTurnStart, enemyTurnEnd, beforeAttack
    }
    
    init(){
        checks = [SkillAbilityList.Check.check0(nil).value]
        activates = [SkillAbilityList.Activate.activate0(nil).value]
    }
    
    fileprivate init(description: String, activateType: ActivateType, activates: [SkillAbilityList.ActivateType], checks: [SkillAbilityList.CheckType]){
        self.description = description
        self.activateType = activateType
        self.activates = activates
        self.checks = checks
    }

    func check(_ player: Player)-> Bool{
        var flag: Bool = true
        checks.forEach{
            if !$0(player){
                flag = false
                return
            }
        }
        return flag
    }
    
    func activate(_ player: Player){
        activates.forEach{
            $0(player)
        }
    }
    /// カードの効果が発動するか確かめてから、効果を発動させる
    ///
    /// - Parameter player: カード所持プレイヤー
    final func checkAndActivate(_ player: Player){
        if check(player){
            activate(player)
        }
    }
}

class SkillList{
    private struct SkillInfo{
        var description: String
        var activateType: String
        var activates: [[Float]]
        var checks: [[Float]]
        
        func convertSkill()-> Skill{
            var newActivates: [SkillAbilityList.ActivateType] = []
            var newChecks: [SkillAbilityList.CheckType] = []
            let newActivateType = Skill.ActivateType(rawValue: activateType)!
            for activate in activates{
                if activate.isEmpty{ break }
                var amountType: SkillAbilityList.AmountValue
                let amount = activate[1]
                if amount >= 0{
                    amountType = SkillAbilityList.Amount.amount0(NSNumber(value: amount))
                }else{
                    amountType = SkillAbilityList.Amount.perform(amount.i * -1)
                }
                let takeValue = SkillAbilityList.Activate.perform(activate[0].i, with: amountType)
                newActivates.append(takeValue)
            }
            for check in checks{
                if check.isEmpty{ break }
                var amountType: SkillAbilityList.AmountValue
                let amount = check[1]
                if amount >= 0{
                    amountType = SkillAbilityList.Amount.amount0(NSNumber(value: amount))
                }else{
                    amountType = SkillAbilityList.Amount.perform(amount.i * -1)
                }
                let takeValue = SkillAbilityList.Check.perform(check[0].i, with: amountType)
                newChecks.append(takeValue)
            }
            return Skill(description: description, activateType: newActivateType, activates: newActivates, checks: newChecks)
        }
    }
    private static var skillInfos: [Int : SkillInfo] = [:]
    public static var list: [Skill]{
        return skillInfos.map({$0.value.convertSkill()})
    }
    
    /// 指定idのスキルを返す
    ///
    /// - Parameter id: id
    /// - Returns: カード
    public static func get(id: Int)-> Skill?{
        return skillInfos[id]?.convertSkill()
    }
    
    private init(){}
    
    
    public static func loadPropertyLocal(){
        let path = Bundle.main.path(forResource: "cardSkill", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        let json = try! JSON(data: data)
        
        let result = json.dictionaryValue["results"]
        for obj in result!.arrayValue{
            let description = obj["description"].stringValue
            let activateType = obj["activateType"].stringValue
            let activates = obj["activate"].rawValue as! [[Float]]
            let checks = obj["check"].rawValue as! [[Float]]
            let id = obj["id"].intValue
            let info = SkillInfo(description: description, activateType: activateType, activates: activates, checks: checks)
            skillInfos[id] = info
        }
    }
    public static func loadProperty(completion: @escaping ErrorBlock){
        if !skillInfos.isEmpty{
            print("SkillList-LoadProperty Called more than second times.")
        }

        print("LoadSkills")

        //サーバーからスキル情報を取得
        //maxは1000なので，これを超えたらサーバー側にクラスを追加
        let query = NCMBQuery(className: "cardSkill")
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

            for object in objects{
                guard let obj = object as? NCMBObject else{
                    fatalError("object Error")
                }
                guard let description = obj.object(forKey: "description") as? String else{
                    print(obj.object(forKey: "description"))
                    fatalError("description Error")
                }


                guard let activateType = obj.object(forKey: "activateType") as? String else{
                    print(obj.object(forKey: "activateType"))
                    fatalError("activateType Error")
                }

                guard let activates = (obj.object(forKey: "activate") as? [[NSNumber]])?.map({ $0.map({ $0.floatValue })}) else{
                    print(obj.object(forKey: "activate"))
                    fatalError("active Error")
                }
                

                guard let checks = (obj.object(forKey: "check") as? [[NSNumber]])?.map({ $0.map({ $0.floatValue })})else{
                    print(obj.object(forKey: "check"))
                    fatalError("check Error")
                }

                guard let id = (obj.object(forKey: "id") as? NSNumber)?.intValue else{
                    print(obj.object(forKey: "id"))
                    fatalError("id Error")
                }

                let info = SkillInfo(description: description, activateType: activateType, activates: activates, checks: checks)
                skillInfos[id] = info
            }
            completion(nil)
        }
    }
}
