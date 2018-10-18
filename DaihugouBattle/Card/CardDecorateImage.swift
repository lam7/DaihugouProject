//
//  CardDecorateImage.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/25.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

//class CardDecorateImage{
//    static func decorateBackgroundAndIndex(_ card: Card)-> UIImage?{
//        return autoreleasepool{
//            guard let original: UIImage = DataRealm.get(imageNamed: card.imageNamed),
//                let background: UIImage = DataRealm.get(imageNamed: "cardBack.png"),
//                let index: UIImage = DataRealm.get(imageNamed: "cardIndex\(card.index).png") else{
//                    return nil
//            }
//            let resize = original.resize(size: background.size)
//            return UIImage.compose([background, resize, index])
//        }
//    }
//}

//class CardDecorateImage: Card{
//    lazy var decoratedImage: UIImage? = {
//        let original: UIImage? = DataRealm.get(imageNamed: imageNamed)
//        let background: UIImage? = DataRealm.get(imageNamed: "cardBack.png")
//        let index: UIImage? = DataRealm.get(imageNamed: "cardIndex\(self.index).png")
//        return UIImage.compose([background, original, index])
//    }()
//}
