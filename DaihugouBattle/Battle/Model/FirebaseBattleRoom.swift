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
    private var isBattling: Bool = false
    
    func setUp(_ completion: @escaping (_ error: Error?) -> ()){
        login{ error in
            if let error = error{
                completion(error)
                return
            }
            self.getRoom()
        }
    }
    
    func login(_ completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signInAnonymously{
            user, error in
            completion(error)
        }
    }
    
    func getRoom(){
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
        let user: [String : String] = [
            "masterObjectId" : UserLogin.objectIdUserInfo,
            "masterName" : UserInfo.shared.nameValue,
            "isMatching" : "0",
            "isWaiting" : "1",
            "isMasterTurn" : (0...1).randomElement()!.description
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
            //このへんでレート補正
            roomId = key as? String
            break
        }
        print("チャット開始するルームId\(roomId!)")
    }
    
    private func decodeMessage(_ dictionary: NSDictionary){
        guard let text = (dictionary["text"] as? String) else{ return }
        let texts = text.components(separatedBy: ",")
        let act = texts[0]
        let value = texts[1]
        switch act{
        case "putDown":
            let cards = (value as! [Int]).map{ CardList.get(id: $0)! }
            delegate?.enemyPutDown(cards)
        case "pass":
            delegate?.enemyPass()
        default:
            print("--------------------------")
            print("FirebaseBattleRoom Error")
            print("act value is mistake")
            print(text)
            
        }
    }
}

