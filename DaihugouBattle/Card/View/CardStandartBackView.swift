//
//  CardBackView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/06/07.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class CardStandartBackView: UINibView{
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    
    fileprivate func setUpViews(){
        imageView.image = DataRealm.get(imageNamed: "trumpBack.png")
    }
}
