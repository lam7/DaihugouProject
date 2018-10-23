//
//  Tutorial.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/23.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import MMPopLabel
import RxSwift

class Tutorial{
    var nextButton: UIButton{
        let b = UIButton(frame: .zero)
        b.setTitle("次へ", for: .normal)
        return b
    }
    
    func start(){
        
    }
    
    func tutorial(_ vc: UIViewController, target: UIView?){
        vc.view.subviews.forEach({
            let button = $0 as? UIButton
            if button == nil{ return }
            if target != nil && target == button{
                button?.isEnabled = true
            }else{
                button?.isEnabled = false
            }
        })
    }
}

class InductionDeckCreateTutorial: Tutorial{
    weak var homeViewController: HomeViewController!
    let disposeBag =  DisposeBag()
    
    override func start(){
        MMPopLabel.appearance().labelColor = #colorLiteral(red: 0.9231043782, green: 0.3642040393, blue: 0.3073337664, alpha: 1)
        MMPopLabel.appearance().labelTextColor = UIColor.white
        MMPopLabel.appearance().labelTextHighlightColor = UIColor.cyan
        MMPopLabel.appearance().labelFont = UIFont(name: "HelveticaNeue-Light", size: 18)
//        MMPopLabel.appearance().buttonFont = UIFont(name: "HelveticaNeue", size: 18)
        startFirst()
    }
    
    private func startFirst(){
        let label = firstWelcome
        let b = UIButton(frame: .zero)
        b.setTitle("OK", for: .normal)
        label.add(b)
        label.didPressButtonHandler{
            _, _ in
            self.startSelectCardButton()
        }
        label.pop(at: homeViewController.view)
    }
    
    private func startSelectCardButton(){
        let target = homeViewController.cardButton!
        tutorial(target, label: selectCardButton, next: startDeckButton)
    }
    
    private func startDeckButton(){
        let target = (homeViewController.cardView as! CardSelectView).deckButton!
        tutorial(target, label: selectDeckButton, next: startCreateDeckButton)
    }
    
    private func startCreateDeckButton(){
        let target = (homeViewController.cardView as! CardSelectView).deckButton!
        tutorial(target, label: selectCreateDeckButton, next: {})
    }
    
    private func tutorial(_ target: UIButton, label: MMPopLabel, next: @escaping () -> ()) {
        homeViewController.view.addSubview(label)
        tutorial(homeViewController, target: target)
        target.rx.tap.subscribe{ event in
            next()
            label.dismiss()
        }.disposed(by: disposeBag)
        label.pop(at: target)
    }
    
    var firstWelcome: MMPopLabel{
        let text = "大プロの世界へようこそ。まずはデッキを作ってみましょう。"
        let l = MMPopLabel(text: text)
        return l!
    }
    var selectCardButton: MMPopLabel{
        let text = "カードボタンを押してください"
        let l = MMPopLabel(text: text)
        return l!
    }
    
    var selectDeckButton: MMPopLabel{
        let text = "デッキボタンを押してください"
        let l = MMPopLabel(text: text)
        return l!
    }
    
    var selectCreateDeckButton: MMPopLabel{
        let text = "デッキ作成ボタンを押してください。"
        let l = MMPopLabel(text: text)
        return l!
    }
}
