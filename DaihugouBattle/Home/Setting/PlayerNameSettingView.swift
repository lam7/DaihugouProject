//
//  PlayerNameSettingView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/26.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class PlayerNameSettingView: UINibView{
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    

    @objc func tapBehind(_ sender: UITapGestureRecognizer){
        removeSafelyFromSuperview()
    }
    
    @IBAction func touchUp(_ sender: UIButton){
        switch sender {
        case okButton:
            settingName()
        case closeButton:
            removeFromSuperview()
        default:
            return
        }
    }

    
    func settingName(){
        guard let name = nameTextField.text else{
            return
        }
        UserInfo.shared.rename(player: name, completion: { error in
            if let error = error{
                let alert = UIAlertController(title: "通信エラー", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {
                    _ in
                    self.removeFromSuperview()
                })
                alert.addAction(ok)
                self.parentViewController()?.present(alert, animated: true, completion: nil)
            }
            self.removeFromSuperview()
        })
    }
    
    override func removeFromSuperview() {
        UIView.animateCloseWindow(self){
            super.removeFromSuperview()
        }
    }
}
