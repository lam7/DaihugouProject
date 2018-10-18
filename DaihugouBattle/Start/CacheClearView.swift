//
//  CacheClearView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import Chameleon

@IBDesignable class CacheClearView: UIView, SelectTrueOrFalseDelegate{
    weak var tfView: SelectTrueOrFalseView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUp()
    }
    
    private func setUp(){
        let tfView = SelectTrueOrFalseView(frame: bounds)
        tfView.delegate = self
        tfView.titleLabel.text = "キャッシュクリア"
        tfView.backgroundColor = UIColor.flatCoffee()
        tfView.descriptionLabel.text =
        "キャッシュデータを削除すると動作が軽くなる場合があります\nまた、プレイデータは削除されません。\nキャッシュクリア後に、改めてデータをダウンロードします。\nキャッシュクリアを実行しますか？"
        tfView.descriptionLabel.backgroundColor = UIColor.flatCoffeeColorDark()
        tfView.descriptionLabel.numberOfLines = 4
        tfView.trueButton.backgroundColor = UIColor.flatRed()
        tfView.falseButton.backgroundColor = UIColor.flatGreen()
        addSubview(tfView)
        self.tfView = tfView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return superview!.point(inside: point, with: event)
    }
    
    func touchUpTrue() {
        ManageAudio.shared.play("click.mp3")
        do{
            //この方法ではRealmからデータは削除されるが、使用容量は変化しない
            try DataRealm.removeAll()
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(nil, forKey: "imageVersion")
            userDefaults.synchronize()
            
            self.removeFromSuperview()
        }catch (let error){
            if let parent = parentViewController() as? StartViewController{
                parent.present(error, title: "キャッシュクリアエラー", completion: nil)
            }else{
                print(error)
            }
        }
    }
    
    func touchUpFalse() {
        ManageAudio.shared.play("click.mp3")
        UIView.animateCloseWindow(self){
            self.removeFromSuperview()
        }
    }
}
