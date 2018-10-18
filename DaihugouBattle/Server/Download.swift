//
//  Download.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/22.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import NCMB
import UIKit

/// 最初の文字と最後の文字を取り除く．
/// "で閉じられていないなら引数をそのまま返す
///
/// サーバーからStringを取ってきた時，最初と最後の文字が"なので
/// このメソッドを使って取り除く．
/// - Parameter character: 文字列
/// - Returns: 1文字目 ~ 最後から一つ前までの文字列
public func deleteDoubleQuotesFirstAndLast(_ character: String)-> String{
    var st = character.index(after: character.startIndex)
    var ed = character.index(before: character.endIndex)
    if character.first != "\""{
        st = character.startIndex
    }
    if character.last != "\""{
        ed = character.endIndex
    }
    return String(character[st ..< ed])
}


/// 最初と最後に"を追加する．
/// すでに"があるなら追加はしない．
///
/// サーバーにStringで保存する時"で囲まれていないと型予測が聞かないので囲んでおく.
/// - Parameter character: 文字列
/// - Returns: " + character + "
public func addDoubleQuotesFirstAndLast(_ character: String)-> String{
    var new = character
    if character.first != "\""{
        new = "\"" + new
    }
    if character.last != "\""{
        new = new + "\""
    }
    return new
}

class DownloadData{
    private var dataRealm: [DataRealm] = []
    private var dataServer: [DataInfo] = []
    private var dataDownload: [DataInfo] = []
    private var dataErased: [DataRealm] = []
    
    var downloadMax: Int{
        return dataDownload.count
    }
    
    private struct DataInfo{
        var version: Int
        var path: String
        var isErased: Bool
    }
    
    func setUpRealm(){
        dataRealm = DataRealm.loadAll()
    }
    
    func setUpServer(_ completion: @escaping (_: Error?) -> ()){
        getDataInfoFromDataBase({
            fileServer,error  in
            if let error = error{
                completion(error)
                return
            }
            
            self.dataServer = fileServer
            for dataServer in fileServer{
                //保存済みで削除命令があるなら
                let erased = self.dataRealm.filter({
                    $0.path == dataServer.path && dataServer.isErased
                })
                if !erased.isEmpty{
                    self.dataErased += erased
                    continue
                }
                
                //保存済みと同バージョンなら
                if !self.dataRealm.filter({
                    $0.path == dataServer.path && $0.version == dataServer.version
                }).isEmpty{
                    continue
                }
                
                //上記のいずれの条件にも当てはまらないならデータ情報を配列に追加
                //この情報はdownload()が呼ばれるときに使われる
                self.dataDownload.append(dataServer)
            }
            completion(nil)
        })
    }
    
    private func getDataInfoFromDataBase(_ completion: @escaping (_: [DataInfo], _: Error?) -> ()){
        var dataInfos: [DataInfo] = []
        let query = NCMBQuery(className: "imagePath")
        query?.addDescendingOrder("version")
        query?.limit = 1000
        
        query?.findObjectsInBackground(){
            objects, error in
            if let error = error{
                completion([], error)
                return
            }
            guard let objects = objects else{
                completion([], NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
                return
            }
            print("objects count " + objects.count.description)
            
            for object in objects{
                guard let obj = object as? NCMBObject else{
                    fatalError("Download-getDataInfo object Error")
                    continue
                }
                guard let version = obj.object(forKey: "version") as? Int else{
                    print(obj.object(forKey: "version"))
                    fatalError("Download-getDataInfo version Error")
                    continue
                }
                guard let path = obj.object(forKey: "path") as? String else{
                    print(obj.object(forKey: "path"))
                    fatalError("Download-getDataInfo path Error")
                    continue
                }
                guard let isErased = obj.object(forKey: "isErased") as? Bool else{
                    print(obj.object(forKey: "isErased"))
                    fatalError("Download-getDataInfo isErased Error")
                    continue
                }
                
                //最初と最後の文字が"なのでそれらを消す
                let st = path.index(after: path.startIndex)
                let ed = path.index(before: path.endIndex)
                let newPath = String(path[st ..< ed])
                
                dataInfos.append(DataInfo(version: version, path: newPath, isErased: isErased))
            }
            print("dataInfos count" + dataInfos.count.description)
            completion(dataInfos, nil)
        }
    }
    
    
    private func getDataFromFileServer(_ path: String, completion: @escaping (_ : Data?, _: Error?) -> ()){
        guard let fileData = NCMBFile.file(withName: path, data: nil) as? NCMBFile else{
            fatalError("Dismiss path   " + path)
        }
    
        
        fileData.getDataInBackground({
            data, error in
            completion(data, error)
        }, progressBlock: {
            progress in
            print(progress)
        })
    }
    
    func erased() throws{
        for data in dataErased{
            try DataRealm.remove(data)
        }
    }
    
    private func downloadSupport(_ dataInfo: DataInfo, completion: @escaping(_ error: Error?) -> ()){
        getDataFromFileServer(dataInfo.path){
            data, error in
            
            if let error = error{
                completion(error)
                return
            }
            if data == nil{
                completion(NSError(domain: "com.Daihugou.app", code: 0, userInfo: nil))
                return
            }
            
            let realm = DataRealm()
            realm.path = dataInfo.path
            realm.version = dataInfo.version
            realm.data = data
            do{
                try realm.write()
            }catch let realmError{
                print("Download-check Can't save new dataInfo")
                print(realmError)
                completion(realmError)
                return
            }
            completion(nil)
        }
    }
    
    func download(_ count: Int = 0, progress: @escaping (_ path: String, _ progress: Int, _ error: Error?) -> (), completion: @escaping () -> ()){
        if !dataDownload.inRange(count){
            completion()
            return
        }
        
        downloadSupport(dataDownload[count]){
            error in
            progress(self.dataDownload[count].path, count + 1, error)
            if error != nil{
                return
            }
            self.download(count + 1, progress: progress, completion: completion)
        }
    }
    
    func downloadAtSameTime(progress: @escaping (_ path: String, _ progress: Int, _ error: Error?) -> (), completion: @escaping () -> ()){
        for count in 0..<dataDownload.count{
            downloadSupport(dataDownload[count]){
                error in
                progress(self.dataDownload[count].path, count + 1, error)
                if DataRealm.loadAll().count == self.dataDownload.count{
                    completion()
                }
            }
        }
       
    }
    
    func check(){
        print("データのチェックを開始します")
        dataRealm = DataRealm.loadAll()
        
        var cnt = -1
        while true{
            cnt += 1
            if !self.dataRealm.inRange(cnt){
                break
            }
            
            let dataRealm = self.dataRealm[cnt]
            if self.dataRealm.filter({
                $0.path == dataRealm.path
            }).count >= 2{
                do{
                    print("remove data " + dataRealm.path)
                    try DataRealm.remove(dataRealm)
                    self.dataRealm.remove(at: cnt)
                    cnt -= 1
                }catch{
                    print(error)
                    continue
                }
            }
        }
        
        
        dataDownload = []
        
        for dataServer in dataServer{
            let dataCnt =  dataRealm.filter({
                $0.path == dataServer.path
            }).count
            if dataCnt == 0{
                dataDownload.append(dataServer)
            }else if dataCnt >= 2{
                print("データが重複しています " + dataServer.path)
            }
        }
    }
}
