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
import RxSwift
import RxCocoa

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

extension Errors{
    class DownloadData{
        static let isNotCorrectDataType: ((String) -> (NSError)) = {
            description in
            var reason = "データの形式が正しくありません。\(description)"
            return NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "ダウンロードエラー",
                                                                       NSLocalizedFailureReasonErrorKey : reason])
        }
        
        static let notExistObjects: NSError = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "ダウンロードエラー",
                                                                                             NSLocalizedFailureReasonErrorKey : "オブジェクトが存在しません"])
        
        static let notExistFileFromServer: NSError = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "ダウンロードエラー",
                                                                                             NSLocalizedFailureReasonErrorKey : "ファイルが存在しません"])
        static let fileDamage: NSError = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "ファイルエラー",
                                                                                             NSLocalizedFailureReasonErrorKey : "ファイルが破損しています。\nキャッシュを削除しデータをダウンロードしなおして下さい。"])
    }
}

class DownloadData{
    private var erasedDatas: [DataInfo] = []
    private var downloadDatas: [DataInfo] = []
    
    var countDownloaded: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var lastDownloadedNamed: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var countDownloadDatas: Int{
        return downloadDatas.count
    }
    
    private struct DataInfo{
        var version: Int
        var path: String
        var isErased: Bool
    }
    
    func setUpServer(_ completion: @escaping ErrorBlock){
        getDataInfoFromDataBase({
            [weak self] dataInfos,error  in
            guard let `self` = self else {
                return
            }
            if let error = error{
                completion(error)
                return
            }
            
            for dataInfo in dataInfos{
                //保存済みで削除命令があるなら
                if dataInfo.isErased && DataRealm.isExisted(dataInfo.path){
                    self.erasedDatas.append(dataInfo)
                    continue
                }
                
                //保存済みと同バージョンなら
                if DataRealm.isExisted(dataInfo.path, version: dataInfo.version){
                    continue
                }
                
                //上記のいずれの条件にも当てはまらないならデータ情報を配列に追加
                //この情報はdownload()が呼ばれるときに使われる
                self.downloadDatas.append(dataInfo)
            }
            completion(nil)
        })
    }
    
    private func getDataInfoFromDataBase(_ completion: @escaping (_: [DataInfo], _: Error?) -> ()){
        var dataInfos: [DataInfo] = []
        let query = NCMBQuery(className: "imagePath")
        query?.limit = 1000
        
        query?.findObjectsInBackground(){
            objects, error in
            if let error = error{
                completion([], error)
                return
            }
            guard let objects = objects else{
                completion([], Errors.DownloadData.notExistObjects)
                return
            }
            print("objects count " + objects.count.description)
            
            for object in objects{
                guard let obj = object as? NCMBObject else{
                    completion([], Errors.DownloadData.notExistObjects)
                    continue
                }
                guard let version = obj.object(forKey: "version") as? Int else{
                    completion([], Errors.DownloadData.isNotCorrectDataType("version: \(obj.object(forKey: "version").debugDescription)"))
                    continue
                }
                guard let path = obj.object(forKey: "path") as? String else{
                    completion([], Errors.DownloadData.isNotCorrectDataType("version: \(obj.object(forKey: "path").debugDescription)"))
                    continue
                }
                guard let isErased = obj.object(forKey: "isErased") as? Bool else{
                    completion([], Errors.DownloadData.isNotCorrectDataType("version: \(obj.object(forKey: "isErased").debugDescription)"))
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
    
    
    private func getDataFromFileServer(_ path: String, progress: @escaping NCMBProgressBlock, completion: @escaping NCMBDataResultBlock){
        let fileData = NCMBFile.file(withName: path, data: nil) as! NCMBFile
        
        fileData.getDataInBackground(completion, progressBlock: progress)
    }
    
    private func downloadSupport(_ dataInfo: DataInfo, completion: @escaping(_ error: Error?) -> ()){
        getDataFromFileServer(dataInfo.path, progress: {
            print(dataInfo.path + ": \($0)")
        }){
            data, error in
            if let error = error{
                completion(error)
                return
            }
            if data == nil{
                completion(Errors.DownloadData.notExistFileFromServer)
                return
            }

            do{
                try DataRealm.add(dataInfo.path, data: data, version: dataInfo.version)
            }catch let realmError{
                print("Download-check Can't save new dataInfo")
                print(realmError)
                completion(realmError)
                return
            }
            completion(nil)
        }
    }
    
    func download(_ count: Int = 0, error: @escaping (_ error: Error) -> (), completion: @escaping () -> ()){
        if self.downloadDatas.outOfRange(count){
            completion()
            return
        }
        let downloadData = downloadDatas[count]
        downloadSupport(downloadData, completion: {
            [weak self] e in
            if let e = e{
                error(e)
                return
            }
            self?.lastDownloadedNamed.accept(downloadData.path)
            self?.countDownloaded.accept(count)
            self?.download(count + 1, error: error, completion: completion)
        })
    }
    
    func erased() throws{
        for data in erasedDatas{
            try DataRealm.remove(data.path)
        }
    }
    
    func check() throws{
        print("データのチェックを開始します")
        for data in downloadDatas{
            if !DataRealm.isExisted(data.path, version: data.version){
                throw Errors.DownloadData.fileDamage
            }
        }
        
        for data in erasedDatas{
            if DataRealm.isExisted(data.path){
                throw Errors.DownloadData.fileDamage
            }
        }
        print("チェック終了")
    }
    
}
