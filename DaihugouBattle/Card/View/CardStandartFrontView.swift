//
//  CardFrontImageView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/06/07.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol DisplayableFromCardInfo{
    func set(from card: Card?)
}

protocol DisplayableAtk{
    func set(atk to: Any?)
}

protocol DisplayableIndex{
    func set(index to: Any?)
}

protocol DisplayableBackground{
    func set(background to: Any?)
}

protocol DisplayableCharacter{
    func set(character to: Any?)
}

protocol DisplayableFrame{
    func set(frame to: Any?)
}

protocol DisplayableName{
    func set(name to: Any?)
}

typealias DisplayableCard = DisplayableFromCardInfo & DisplayableAtk & DisplayableIndex & DisplayableBackground & DisplayableCharacter & DisplayableFrame & DisplayableName

class CardStandartFrontView: UIView, DisplayableCard{
    var frontFrameLayer: CardFrontFrameLayer!
    var backFrameLayer: CardBackFrameLayer!
//    var atkLayer: CALayer!
    var characterImageLayer: CALayer!
    var backgroundImageLayer: CALayer!
    
    var nameView: CardNameView!
    var indexView: CardIndexView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let backFrameLayer = CardBackFrameLayer()
        layer.addSublayer(backFrameLayer)
        self.backFrameLayer = backFrameLayer
        
        let backgroundImageLayer = CALayer()
        layer.addSublayer(backgroundImageLayer)
        self.backgroundImageLayer = backgroundImageLayer
        
        let characterImageLayer = CALayer()
        layer.addSublayer(characterImageLayer)
        self.characterImageLayer = characterImageLayer
        
        let frontFrameLayer = CardFrontFrameLayer()
        layer.addSublayer(frontFrameLayer)
        self.frontFrameLayer = frontFrameLayer
        
//        let nameLayer = CardNameLayer()
//        layer.addSublayer(nameLayer)
//        self.nameLayer = nameLayer
        let nameView = CardNameView()
        addSubview(nameView)
        self.nameView = nameView
        
//        let indexLayer = CardIndexLayer()
//        layer.addSublayer(indexLayer)
//        self.indexLayer = indexLayer
        let indexView = CardIndexView()
        addSubview(indexView)
        self.indexView = indexView
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

//        nameView.frame.origin = CGPoint(x: 0, y: characterImageView.frame.minY - nameView.frame.height)
//        indexView.center = CGPoint(x: 0, y: nameView.frame.midY)
        
        let height = rect.height * 0.85
        let width = height / 4 * 3
        let dx = rect.width - width
        let dy = rect.maxY - height;
        let frame = CGRect(x: dx / 2, y: dy, width: width, height: height)
        
        characterImageLayer.frame = frame
        backgroundImageLayer.frame = frame
        
        backFrameLayer.frame = bounds
        frontFrameLayer.frame = bounds
        
        
//        indexLayer.frame = CGRect(x: -indexHeight / 2, y: 0, width: indexHeight, height: indexHeight)
//        nameLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: indexHeight)
        
        let nameHeight = rect.height * 0.15
        nameView.frame = CGRect(x: 0, y: characterImageLayer.frame.minY - nameHeight , width: bounds.width, height: nameHeight)
        
        let indexHeight = rect.height * 0.25
        indexView.frame = CGRect(x: -indexHeight / 2, y: nameView.frame.minY, width: indexHeight, height: indexHeight)
    }

    func set(from card: Card?) {
        set(atk: card?.atk)
        set(index: card?.index)
        if let imageNamed = card?.imageNamed{
            RealmImageCache.shared.imageInBackground(imageNamed, completion: {
                self.set(character: $0)
                self.setNeedsLayout()
                self.layoutIfNeeded()
            })
        }else{
            set(character: nil)
        }
        
        RealmImageCache.shared.imageInBackground("cardBack.png", completion: {
            self.set(background: $0)
        })
        
        set(name: card?.name)
    }

    func set(name to: Any?) {
        guard let to = to as? String else{
            nameView.isHidden = true
            return
        }
        nameView.isHidden = false
        nameView.text = to
    }
    func set(atk to: Any?) {

    }

    func set(index to: Any?) {
        guard let to = to as? Int else{
            indexView.isHidden = true
            return
        }
        indexView.isHidden = false
        indexView.set(index: to)
    }

    func set(background to: Any?) {
        guard let to = to as? UIImage else{
            backgroundImageLayer.contents = nil
            return
        }
        backgroundImageLayer.contents = to.cgImage
    }

    func set(character to: Any?) {
        guard let to = to as? UIImage else{
            characterImageLayer.contents = nil
            return
        }
        characterImageLayer.contents = to.cgImage
//        characterImageView.image = to
    }

    func set(frame to: Any?) {

    }
}



