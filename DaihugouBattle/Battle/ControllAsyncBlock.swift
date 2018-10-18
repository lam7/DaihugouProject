//
//  ControllAsyncBlock.swift
//  DaihugouBattle
//
//  Created by Main on 2018/03/28.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation


///　非同期処理で連続で呼ばれる処理郡を、
/// 1つめの処理終了ー＞２つめの処理開始・・・となるように変換するクラス
final class ControllAsyncBlock{
    private var blocks: [()->()] = []
    /// 処理中かどうか
    private(set) var isAsyncing = false
    
    /// 次の処理へ行く
    func next(){
        guard let block = blocks.remove(safe: 1) else{
            isAsyncing = false
            blocks = []
            return
        }
        block()
    }
    
    
    /// 処理を加える
    ///
    /// blockの中でnextを呼ぶ。
    ///
    /// - Parameter block: 処理ブロック
    func add(block: @escaping () -> ()){
        isAsyncing = true
        if blocks.isEmpty{
            blocks.append({})
            block()
        }else{
            blocks.append(block)
        }
    }
    
    /// 全処理を開放する
    func clear(){
        blocks = []
    }
}
