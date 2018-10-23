//
//  MMPopLabel+.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/23.
//  Copyright © 2018 Main. All rights reserved.
//
// 引用
// https://qiita.com/hmhmsh/items/0127cbf093b93afde7c3

import Foundation
import MMPopLabel
// MMPopLabelにMMPopLabelDelegateをつける
extension MMPopLabel: MMPopLabelDelegate {
    
    // 引数にpopが消えた時のclosureを入れる
    public func dismissedHandler(_ handler:@escaping (MMPopLabel) -> Void) {
        // 自分自身にdeleagateを設定
        self.delegate = self
        // closure管理クラスにclosureを渡す
        MMPopLabelDelegateSingleton.standard.dismissedHandler = handler
    }
    
    // 引数にpop内に設置したボタンが押された時のclosureを入れる
    public func didPressButtonHandler(_ handler:@escaping (MMPopLabel, Int) -> Void) {
        self.delegate = self
        MMPopLabelDelegateSingleton.standard.didPressButtonHandler = handler
    }
    
    // MMPopLabelDelegateメソッド
    public func dismissedPopLabel(_ popLabel: MMPopLabel!) {
        // 対応するclosureがあれば呼び出す
        guard let dismissedHandler = MMPopLabelDelegateSingleton.standard.dismissedHandler else {
            return
        }
        dismissedHandler(popLabel)
    }
    
    // MMPopLabelDelegateメソッド
    public func didPressButton(for popLabel: MMPopLabel!, at index: Int) {
        guard let didPressButtonHandler = MMPopLabelDelegateSingleton.standard.didPressButtonHandler else {
            return
        }
        didPressButtonHandler(popLabel, index)
    }
}

// closure管理クラス
fileprivate class MMPopLabelDelegateSingleton {
    static let standard = MMPopLabelDelegateSingleton()
    
    var dismissedHandler:((MMPopLabel) -> Void)?
    var didPressButtonHandler:((MMPopLabel, Int) -> Void)?
    
}
