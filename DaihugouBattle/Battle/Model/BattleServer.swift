//
//  BattleServer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/05.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


class BattleServer{
    var battleField: BattleField!
    private let rootRef = Database.database().reference()
    private let userRef  = Database.database().reference().child("users")
    private var roomId: String!
    private var newRoomId: String!
    private var targetId: String!
    private var chatStartFlg: Bool!
    private let userPath: String = UUID().uuidString
    
    func setUp(){
        login({_ in})
    }
    
    func login(_ completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signInAnonymously{
            user, error in
            completion(error)
        }
    }
    
    func getRoom(){
        let user: [String : String] = [
            "objectId" : UserLogin.objectIdUserInfo,
            "name" : UserInfo.shared.nameValue,
            "inRoom" : "0",
            "waitingFlg" : "0",
        ]

        userRef.child(userPath).setValue(user)
        
        //一回だけwaitingFlgが１のユーザを取得
        userRef.queryOrdered(byChild: "waitingFlg").queryEqual(toValue: "1").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                if value.count >= 1{
                    //ルームを作る側の処理
                    print(value.count);
                    print("value \(value)")
                    print("↑初回ボタン押下時に、waitingFlgが１のユーザ")
                    self.createRoom(value: value as! Dictionary<AnyHashable, Any>)
                }
            } else {
                //ルームを作られるのを待つ側の処理
                self.userRef.child(self.userPath).updateChildValues(["waitingFlg":"1"])
                self.checkMyWaitingFlg()
            }
        })
    }
    
    private func checkMyWaitingFlg(){
        userRef.child(userPath).observe(DataEventType.childChanged, with: { (snapshot) in
            print(snapshot)
            let snapshotVal = snapshot.value as! String
            let snapshotKey = snapshot.key
            
            if (snapshotVal == "0" && snapshotKey == "waitingFlg"){
                self.getJoinRoom()
            }
        })
    }
    
    private func getJoinRoom(){
        userRef.child(userPath).child("inRoom").observeSingleEvent(of: .value, with: { (snapshot) in
            //返ってくる値が１つしか無いからstr型になる
            let snapshotValue = snapshot.value as! String
            self.roomId = snapshotValue
            if(self.roomId != "0"){
                print("roomId→ \(self.roomId!)")
                print("チャットを開始します")
                self.getMessages()
            }
        })
        
    }
    
    private func createRoom(value:Dictionary<AnyHashable, Any>){
        
        //chatを始めるユーザを取得。
        
        for (key,val) in value {
            
            if (key as! String != userPath){
                //待機中のユーザがいた場合(必ずこの処理で居るが)の処理
                print("待機中のユーザId\(key)")
                targetId = key as? String
            }
        }
        print("チャット開始するユーザId\(targetId!)")
        //新規のRoomを作るための数値を取得
        getNewRoomId()
    }
    
    private func getNewRoomId(){
        
        Database.database().reference().child("roomKeyNum").observeSingleEvent(of: .value, with: { (snapshot) in
            var count: Int = -1
            if !(snapshot.value is NSNull){
                count = (snapshot.value as! Int) + 1
            }else{
                print("getNewRoomId error")
                return
            }
            Database.database().reference()
                .child("roomKeyNum")
                .setValue(count)
            
            self.newRoomId = String(count)
            self.updateEachUserInfo()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    private func updateEachUserInfo(){
        
        roomId = newRoomId
        
        //ユーザ情報を書き換えていく。
        userRef.child(userPath).updateChildValues(["inRoom" : roomId!])
        userRef.child(userPath).updateChildValues(["waitingFlg" : "0"])
        
        //新しく作ったルームのidの情報を取ってくる処理【非同期】
        getMessages()
    }
    
    private func getMessages(){
        chatStartFlg = true
        
        //【非同期】子要素が増えるたびにmessageに値を追加する。
        rootRef.child("rooms").child(roomId!).queryLimited(toLast: 100).observe(DataEventType.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            let text          = snapshotValue["text"] as! String
            let sender        = snapshotValue["from"] as! String
            let name          = snapshotValue["name"] as! String
            
            print("display名前→\(name)")
        })
    }
}
