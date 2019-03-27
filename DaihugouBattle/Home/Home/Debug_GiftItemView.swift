//
//  Debug_GiftItemView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/09.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit



class Debug_GiftItemView: UINibView{
    @IBOutlet weak var minuteField: UITextField!
    @IBOutlet weak var hourField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var subIdField: UITextField!
    @IBOutlet weak var idField: UITextField!

    @IBAction func gift(_ sebnder: Any) {
        
        guard let id = idField.text?.i,
            let subId = subIdField.text?.i,
            let count = countField.text?.i,
            let description = descriptionField?.text,
            let day = dayField.text?.d,
            let hour = hourField.text?.d,
            let minute = minuteField.text?.d else{
                idField.text = "正常でない値があります"
                return
        }
        let timeStamp = Date()
        let d = 60 * 60 * 24 * day
        let h = 60 * 60 * hour
        let m = 60 * minute
        let timeLimit = timeStamp.addingTimeInterval(d + h + m)
        let giftItemInfo = GiftedItem(timeStamp: timeStamp, timeLimit: timeLimit, id: id, subId: subId, title: "", description: description, count: count, imageNamed: "TreasureChest.png")
        UserInfo.shared.gift(item: giftItemInfo, completion: {error in
            print(error)
            print("success")
            self.removeFromSuperview()
        })
    }
    
    @IBAction func close(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    override func removeFromSuperview() {
        UIView.animateCloseWindow(self){
            super.removeFromSuperview()
        }
    }
    
}
