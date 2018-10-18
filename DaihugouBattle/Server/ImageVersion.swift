//
//  ImageVersion.swift
//  DaihugouBattle
//
//  Created by Main on 2018/02/02.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import NCMB

final class DefineServer{
    private var infos: [String : Any] = [:]
    public static var shared: DefineServer = DefineServer()
    private init(){}
    
    func loadProperty(_ completion: @escaping (_: Error?)-> ()){
        infos = [:]
        let query = NCMBQuery(className: "define")
        query?.limit = 1000
        query?.findObjectsInBackground(){
            [weak self]objects, error in
            guard let `self` = self else {
                return
            }
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
                guard let key = obj.object(forKey: "key") as? String else{
                    print(obj.object(forKey: "key"))
                    fatalError("key Error")
                }
                
                
                guard let value = obj.object(forKey: "value") else{
                    print(obj.object(forKey: "value"))
                    fatalError("value Error")
                }
                self.infos[key] = value
            }
            completion(nil)
        }
    }
    
    func value(_ forKey: String)-> Any{
        return infos[forKey]
    }
    
    func nsNumber(_ forKey: String)-> NSNumber{
        return infos[forKey] as! NSNumber
    }
    
    func floatValue(_ forKey: String)-> Float{
        return nsNumber(forKey).floatValue
    }
}
class ImageVersion{
    static func isLatest()-> Bool{
        let userDefaults: UserDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "imageVersion") == nil{
            return false
        }
        let currentImageVersion = userDefaults.float(forKey: "imageVersion")
        let newImageVersion = getLatestVersion()
        print("currentImageVersion \(currentImageVersion)")
        print("newImageVersion \(newImageVersion)")
        return newImageVersion == currentImageVersion
    }
    
    static func getLatestVersion()-> Float{
        return DefineServer.shared.floatValue("imageVersion")
    }
}

extension NCMBObject{
    func floatValue(forKey: String)-> Float?{
        return (object(forKey: forKey) as? NSNumber)?.floatValue
    }
    
    func intValue(forKey: String)-> Int?{
        return (object(forKey: forKey) as? NSNumber)?.intValue
    }
}
