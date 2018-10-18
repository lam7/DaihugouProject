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
import SwiftyGif

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
    
    static func get(gifNamed named: String)-> UIImage?{
        guard let data = get(dataNamed: named) else{
            return nil
        }
        let image = UIImage(gifData: data)
        return image
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
    
    static func removeAll() throws{
        if realm == nil{
            realm = try Realm()
        }
        try realm?.write{
            let all = DataRealm.loadAll()
            all.forEach{
                realm?.delete($0)
            }
            //            realm?.invalidate()
            //            if let url = Realm.Configuration.defaultConfiguration.fileURL {
            //                try FileManager().removeItem(at: url)
            //            }
        }
    }
    
    func write() throws{
        if DataRealm.realm == nil{
            DataRealm.realm = try Realm()
        }
        
        try DataRealm.realm?.write{
            DataRealm.realm?.add(self, update: true)
        }
    }
}
