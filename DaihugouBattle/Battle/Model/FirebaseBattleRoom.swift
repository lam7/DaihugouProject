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
    
    private var roomId: String = ""
    private(set) var isBattling: Bool = false
    private(set) var isYourTurn: Bool = false
    private var turn: Int = 0
    
    private typealias UserDictionary = [String : User]
    private typealias IdUser = (id: String, user: User)
    private var maxHP: Int
    private var isMaster: Bool = false
    
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
    
    init(maxHP: Int){
        self.maxHP = maxHP
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
            self.matchingRoom({error in
                completion(error)
            })
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
                self.isMaster = false
                self.enterRoom(roomId){
                    self.startBattle()
                    completion(nil)
                }
            }else{
                self.isMaster = true
                self.createRoom()
                self.observeIsMatching {
                    self.updateIsMatching()
                    self.startBattle()
                    completion(nil)
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
            self.isYourTurn.toggle()
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
        observeLogs()
    }
    
    private func observeLogs(){
        roomRef.child("\(roomId)/logs").observe(.childAdded){ snapshot in
            print("--------------gremgregmrepgremopgermgoperg----------")
            guard let log = snapshot.value as? NSDictionary else{
                return
            }
            if let id = log["id"] as? String,
                id != UserLogin.uuid{
                self.decodeMessage(log)
            }
        }
    }
    
    func exchangePlayerInfo(_ completion: @escaping(_ maxHP: Int, _ name: String, _ id: String)->()){
        let isMaster = self.isMaster ? "master" : "guest"
        let isGuest = self.isMaster  ? "guest" : "master"
        var name: String = ""
        var id: String = ""
        var maxHP: Int = 0
        roomRef.child("\(roomId)").observeSingleEvent(of: .value){ snapshot in
            guard let dictionary = snapshot.value as? NSDictionary else{
                return
            }
            name = dictionary["\(isMaster)Name"] as! String
            id   = dictionary["\(isMaster)ObjectId"] as! String
        }
        roomRef.child("\(roomId)/\(isGuest)MaxHP").observe(.value){ snapshot in
            guard let hp = snapshot.value as? Int else{
                return
            }
            self.roomRef.child("\(self.roomId)/\(isGuest)MaxHP").removeAllObservers()
            maxHP = hp
            
            if self.isMaster{
                self.roomRef.child("\(self.roomId)/isReady").setValue(true)
                completion(maxHP, name, id)
            }
        }
        roomRef.child("\(roomId)/\(isMaster)MaxHP").setValue(self.maxHP)
        
        if !self.isMaster{
            roomRef.child("\(roomId)/isReady").observe(.value){ snapshot in
                guard let isReady = snapshot.value as? Bool else{
                    return
                }
                self.roomRef.child("\(self.roomId)/isReady").removeAllObservers()
                completion(maxHP, name, id)
            }
        }
    }
    
    func drawInitial(_ cards: [Card], completion: @escaping(_ cards: [Card])->()){
        let isMaster = self.isMaster ? "master" : "guest"
        let isGuest = self.isMaster  ? "guest" : "master"
        roomRef.child("\(roomId)/\(isMaster)drawInitial").setValue(cards.map({$0.id}))
        roomRef.child("\(roomId)/\(isGuest)drawInitial").observe(.value){ snapshot in
            guard let ids = snapshot.value as? [Int] else{
                return
            }
            self.roomRef.child("\(self.roomId)/\(isGuest)drawInitial").removeAllObservers()
            let cards = ids.map({ CardList.get(id: $0) ?? cardNoData })
            completion(cards)
        }
    }
    
    func ready(_ completion: @escaping()->()){
        let isMaster = self.isMaster ? "master" : "guest"
        let isGuest = self.isMaster  ? "guest" : "master"
        roomRef.child("\(roomId)/\(isMaster)Ready").setValue(true)
        roomRef.child("\(roomId)/\(isGuest)Ready").observe(.value){ snapshot in
            guard let isReady = snapshot.value as? Bool else{
                return
            }
            self.roomRef.child("\(self.roomId)/\(isGuest)Ready").removeAllObservers()
            completion()
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
            turn += 1
            delegate?.enemyPutDown(cards.compactMap({ $0 }))
        case "pass":
            turn += 1
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
            turn += 1
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
            "id" : UserLogin.uuid,
            "act" : "putDown",
            "value" : cards.map({$0.id})
        ]
        turn += 1
        roomRef.child(roomId).child("logs/\(turn)").setValue(post)
    }

    func encodeMessagePass(){
        let post: [String : Any] = [
            "id" : UserLogin.uuid,
            "act" : "pass",
            "value" : ""
        ]
        turn += 1
        roomRef.child(roomId).child("logs/\(turn)").setValue(post)
    }

    func encodeMessageDraw(_ cards: [Card]){
        let post: [String : Any] = [
            "id" : UserLogin.uuid,
            "act" : "drawCards",
            "value" : cards.map({$0.id})
        ]
        turn += 1
        roomRef.child(roomId).child("logs/\(turn)").setValue(post)
    }
}
