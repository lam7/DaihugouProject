//
//  FirebaseBattleRoom.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/22.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

protocol FirebaseBattleRoomDelegate: class{
    func enemyPutDown(_ cards: [Card])
    func enemyPass()
}

class FirebaseBattleRoom{
    weak var delegate: FirebaseBattleRoomDelegate?
    
    private let rootRef = Database.database().reference()
    private let userRef  = Database.database().reference().child("users")
    private var roomId: String!
    private(set) var isBattling: Bool = false
    private(set) var isYourTurn: Bool = false
    
    
    func setUp(_ completion: @escaping (_ error: Error?) -> ()){
        login{ error in
            if let error = error{
                completion(error)
                return
            }
            self.getRoom()
        }
    }
    
    private func login(_ completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signInAnonymously{
            user, error in
            completion(error)
        }
    }
    
    private func getRoom(){
        //一回だけwaitingFlgが１のユーザを取得
        userRef.queryOrdered(byChild: "isWaiting").queryEqual(toValue: "1").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                if value.count >= 1{
                    //すでに待機中のプレイヤーがいる
                    self.mathingRoom(value as! Dictionary<AnyHashable, Any>)
                }
            } else {
                //待機中のプレイヤーがいないなら
                self.roomMaster()
            }
        })
    }
    
    private func roomMaster(){
        //部屋を作り待機
        createNewRoom()
        observeIsMathing(getMessages)
    }
    
    private func createNewRoom(){
        self.roomId = UUID().uuidString
        let isYourTurn = Bool.random()
        self.isYourTurn = isYourTurn
        let user: [String : String] = [
            "masterObjectId" : UserLogin.objectIdUserInfo,
            "masterName" : UserInfo.shared.nameValue,
            "isMatching" : "0",
            "isWaiting" : "1",
            "isMasterTurn" : isYourTurn ? "1" : "0"
        ]
        userRef.child(roomId).setValue(user)
    }
    
    private func observeIsMathing(_ completion: @escaping () -> ()){
        userRef.child(roomId).observe(DataEventType.childChanged, with: { (snapshot) in
            let snapshotVal = snapshot.value as! String
            let snapshotKey = snapshot.key
            if (snapshotVal == "1" && snapshotKey == "isMatching"){
                completion()
            }
        })
    }
    
    private func getMessages(){
        isBattling = true
        //【非同期】子要素が増えるたびにmessageに値を追加する。
        
        userRef.child(roomId).child("battleLogs").queryLimited(toLast: 1000).observe(DataEventType.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            self.decodeMessage(snapshotValue)
        })
    }
    
    private func roomChild(_ rooms: Dictionary<AnyHashable, Any>){
        mathingRoom(rooms)
        getMessages()
    }
    
    private func mathingRoom(_ value: Dictionary<AnyHashable, Any>){
        //対戦を始める相手を決定する
        for (key,val) in value {
            if key == ""
            //このへんでレート補正
            roomId = key as? String
            break
        }
        print("チャット開始するルームId\(roomId!)")
    }
    
    
    private func decodeMessage(_ dictionary: NSDictionary){
        guard let id = dictionary["id"] as? String,
            id == UserLogin.objectIdUserInfo,
            let act = dictionary["act"] as? String,
            let value = dictionary["value"] as? String else{ return }
        switch act{
        case "putDown":
            guard let array = value as? [Int] else{
                print("--------------------------")
                print("FirebaseBattleRoom Error")
                print("value is mistake")
                print(value)
                return
            }
            
            let cards = array.map({ CardList.get(id: $0) })
            guard !cards.contains(nil) else{
                print("--------------------------")
                print("FirebaseBattleRoom Error")
                print("value is mistake")
                print(array)
                return
            }
            delegate?.enemyPutDown(cards.compactMap({ $0 }))
        case "pass":
            delegate?.enemyPass()
        default:
            print("--------------------------")
            print("FirebaseBattleRoom Error")
            print("act is mistake")
            print(act)
            
        }
    }
    
    func encodeMessagePutDown(_ cards: [Card]){
        let post: [String : Any] = [
            "id" : UserLogin.objectIdUserInfo,
            "act" : "putDown",
            "value" : cards.map({$0.id})
        ]
        userRef.child(roomId).child("battleLogs").setValue(post)
    }
    
    func encodeMessagePass(_ cards: [Card]){
        let post: [String : Any] = [
            "id" : UserLogin.objectIdUserInfo,
            "act" : "pass",
            "value" : ""
        ]
        userRef.child(roomId).child("battleLogs").setValue(post)
    }
}

