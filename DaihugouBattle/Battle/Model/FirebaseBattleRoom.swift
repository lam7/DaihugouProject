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
    func matching()
    func startOwnerTurn()
    func startEnemyTurn()
    func enemyPutDown(_ cards: [Card])
    func enemyPass()
    func enemyDraw(_ cards: [Card])
}

extension Errors{
    class FirebaseBattle{
        static let dataError = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "通信エラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "データの形式が正しくありません"])
    }
}

class FirebaseBattleRoom{
    weak var delegate: FirebaseBattleRoomDelegate?
    
    private let rootRef = Database.database().reference()
    private let userRef  = Database.database().reference().child("battleUsers")
    private let ownerRef = Database.database().reference().child("battleUsers/\(UserLogin.uuid!)")
    private let roomRef = Database.database().reference().child("battleRooms")
    
    private var roomId: String!
    private(set) var isBattling: Bool = false
    private(set) var isYourTurn: Bool = false
    private var turn: Int = 0
    
    private typealias UserDictionary = [String : User]
    private typealias IdUser = (id: String, user: User)
    
    private struct User{
        var roomId: String
        var isMatching: Bool
        
        init(roomId: String, isMatching: Bool){
            self.roomId     = roomId
            self.isMatching = isMatching
        }
        
        init?(nsDictionary: NSDictionary){
            guard let roomId = nsDictionary["roomId"] as? String,
                let isMatching = nsDictionary["isMatching"] as? Bool else{
                    return nil
            }
            
            self.roomId     = roomId
            self.isMatching = isMatching
        }
        
        static func empty()-> User{
            return User(roomId: "", isMatching: false)
        }
        
        func nsDictionary()-> NSDictionary{
            return [
                "roomId" : roomId,
                "isMatching" : isMatching
            ]
        }
    }
    
    private struct Room{
        var masterObjectId: String
        var masterName: String
        var guestObjectId: String
        var guestName: String
        var isMasterTurn: Bool
        var isBattling: Bool
        var logs: [String]
        
        static func empty()-> Room{
            return Room(masterObjectId: UserLogin.uuid, masterName: UserInfo.shared.nameValue, guestObjectId: "", guestName: "", isMasterTurn: Bool.random(), isBattling: false, logs: [])
        }
        
        func nsDictionary()-> NSDictionary{
            return [
                "masterObjectId" : masterObjectId,
                "masterName" : masterName,
                "guestObjectId" : guestObjectId,
                "guestName" : guestName,
                "isBattling" : isBattling,
                "isMasterTurn" : isMasterTurn,
                "logs" : logs
            ]
        }
    }
    
    /// ログインし部屋を探す
    func setUp(_ completion: @escaping (_ error: Error?) -> ()){
        login{ error in
            if let error = error{
                completion(error)
                return
            }
            self.createUserInfo()
            self.matchingRoom({_ in})
        }
    }
    
    private func login(_ completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signInAnonymously{
            user, error in
            completion(error)
        }
    }
    
    private func createUserInfo(){
        ownerRef.setValue(User.empty().nsDictionary())
    }

    private func matchingRoom(_ completion: @escaping (_ error:  Error?) -> ()){
        userRef.observeSingleEvent(of: .value){ snapshot in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            let users = self.convertUserDictionary(value)
            let idUser = self.getMatchableUser(users)
            
            if let idUser = idUser{
                let roomId = idUser.user.roomId
                self.enterRoom(roomId){
                    self.startBattle()
                }
            }else{
                self.createRoom()
                self.observeIsMatching {
                    self.updateIsMatching()
                    self.startBattle()
                }
            }
        }
    }
    
    private func convertUserDictionary(_ users: NSDictionary)-> UserDictionary{
        var results: UserDictionary = [:]
        for user in users{
            guard let id = user.key as? String,
                let dictionary = user.value as? NSDictionary,
                let user = User(nsDictionary: dictionary) else{
                    continue
            }
            results[id] = user
        }
        return results
    }
    
    private func getMatchableUser(_ users: UserDictionary)-> IdUser?{
        guard let user = users.filter({ $0.key != UserLogin.uuid && !$0.value.isMatching}).randomElement() else{
            return nil
        }
        return IdUser(id: user.key, user: user.value)
    }
    
    private func enterRoom(_ roomId: String, completion: @escaping ()->()){
        let values = [
            "guestObjectId" : UserLogin.uuid,
            "guestName" : UserInfo.shared.nameValue,
            "isBattling" : true
            ] as [String : Any]
        roomRef.child(roomId).updateChildValues(values)
        self.roomId = roomId
        updateIsMatching()
        updateRoomId(roomId)
        
        roomRef.child(roomId).child("isMasterTurn").observeSingleEvent(of: .value, with: {
            snapshot in
            self.isYourTurn = snapshot.value as! Bool
            completion()
        })
    }
    
    private func createRoom(){
        let room = Room.empty()
        self.isYourTurn = room.isMasterTurn
        let roomId = UUID.init().uuidString
        self.roomId = roomId
        updateRoomId(roomId)
        roomRef.child(roomId).setValue(room.nsDictionary())
    }
    
    private func observeIsMatching(_ completion: @escaping ()->()){
        roomRef.child(roomId).observeSingleEvent(of: .childChanged){ snapshot in
            completion()
        }
    }
    
    private func updateRoomId(_ roomId: String){
        ownerRef.updateChildValues(["roomId" : roomId])
    }
    
    private func updateIsMatching(){
        ownerRef.updateChildValues(["isMatching" : true])
    }
    
    private func startBattle(){
        delegate?.matching()
        startTurn()
        observeLogs()
    }
    
    private func startTurn(){
        if isYourTurn{
            delegate?.startOwnerTurn()
        }else{
            delegate?.startEnemyTurn()
        }
    }
    
    private func observeLogs(){
        roomRef.child("\(roomId)/logs").observe(.childChanged){ snapshot in
            guard let logs = snapshot.value as? [Int : NSDictionary],
                let log = logs.sorted(by: { $0.key < $1.key }).last?.value else{
                return
            }
            if let id = log["id"] as? String,
                id != UserLogin.uuid{
                self.decodeMessage(log)
            }
        }
    }

    private func decodeMessage(_ dictionary: NSDictionary){
        guard let act = dictionary["act"] as? String else{ return }
        let value = dictionary["value"]
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
        case "drawCards":
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
            delegate?.enemyDraw(cards.compactMap({ $0 }))
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
        turn += 1
        roomRef.child(roomId).child("logs/\(turn)").setValue(post)
    }

    func encodeMessagePass(_ cards: [Card]){
        let post: [String : Any] = [
            "id" : UserLogin.objectIdUserInfo,
            "act" : "pass",
            "value" : ""
        ]
        turn += 1
        roomRef.child(roomId).child("logs/\(turn)").setValue(post)
    }

    func encodeMessageDraw(_ cards: [Card]){
        let post: [String : Any] = [
            "id" : UserLogin.objectIdUserInfo,
            "act" : "drawCards",
            "value" : cards.map({$0.id})
        ]
        turn += 1
        roomRef.child(roomId).child("logs/\(turn)").setValue(post)
    }
}
