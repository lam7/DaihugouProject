//
//  DataRealm.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/21.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class DataRealm: Object{
    private static var realm: Realm? = try? Realm()
    @objc dynamic var data: Data? = nil
    @objc dynamic var path: String = ""
    @objc dynamic var version: Int = 0
    
    override class func primaryKey() -> String{
        return "path"
    }
    
    static func loadAll() -> [DataRealm] {
        if realm == nil{
            realm = try? Realm()
        }
        guard let datas = realm?.objects(DataRealm.self).sorted(byKeyPath: "path", ascending: true) else{
            return []
        }
        return datas.map{$0}
    }
    
    static func isExisted(_ named: String)-> Bool{
        if realm == nil{
            realm = try? Realm()
        }
        
        return realm?.object(ofType: DataRealm.self, forPrimaryKey: named) != nil
    }
    
    static func isExisted(_ named: String, version: Int)-> Bool{
        if realm == nil{
            realm = try? Realm()
        }
        
        guard let object = realm?.object(ofType: DataRealm.self, forPrimaryKey: named) else{
            return false
        }
        
        return object.version == version
    }
    
    
    static func get(dataNamed named: String)-> Data?{
        if realm == nil{
            realm = try? Realm()
        }
        
        guard let datas = realm?.objects(DataRealm.self).filter("path == %@", named),
            let data = datas.first else{
                print("DataRealm not contain \(named).")
                return nil
        }
        
        if datas.count >= 2{
            print("DataRealm have two or more datas named \(named). Plase delete these.")
        }
        return data.data
    }
    
    static func get(imageNamed named: String)-> UIImage?{
        guard let data = get(dataNamed: named) else{
            return nil
        }
        return UIImage(data: data)
    }
    
    static func getBackground(imageNamed: String, completion: @escaping ((_ image: UIImage?) -> ())){
        guard let data = get(dataNamed: imageNamed) else{
            completion(nil)
            return
        }
        DispatchQueue.global().async {
            completion(UIImage(data: data))
        }
    }
    
    static func remove(_ dataRealm: DataRealm) throws{
        if realm == nil{
            realm = try Realm()
        }
        try realm?.write {
            realm?.delete(dataRealm)
        }
    }
    
    static func remove(_ path: String) throws{
        if realm == nil{
            realm = try Realm()
        }
        
        guard let object = realm?.object(ofType: DataRealm.self, forPrimaryKey: path) else{
            print("DataRealm: Irregal path.\(path)")
            return
        }
        try realm?.write {
            realm?.delete(object)
        }
    }
    
    static func add(_ path: String, data: Data?, version: Int) throws{
        let dataRealm = DataRealm()
        dataRealm.path = path
        dataRealm.data = data
        dataRealm.version = version
        try dataRealm.write()
    }
    
    static func removeAll() throws{
        if realm == nil{
            realm = try Realm()
        }
        try realm?.write{
            let all = DataRealm.loadAll()
            all.forEach{
                realm?.delete($0)
            }
        }
    }
    
    func write() throws{
        if DataRealm.realm == nil{
            DataRealm.realm = try Realm()
        }
        
        try DataRealm.realm?.write{
            DataRealm.realm?.add(self, update: .all)
        }
    }
}
