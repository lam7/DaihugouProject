//
//  CacheClearView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

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
        tfView.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        tfView.descriptionLabel.text =
        "キャッシュデータを削除すると動作が軽くなる場合があります\nまた、プレイデータは削除されません。\nキャッシュクリア後に、改めてデータをダウンロードします。\nキャッシュクリアを実行しますか？"
        tfView.descriptionLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tfView.descriptionLabel.numberOfLines = 4
        tfView.trueButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        tfView.falseButton.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
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
