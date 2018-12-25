//
//  Tutorial.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/23.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
//import MMPopLabel
import RxSwift

//class Tutorial{
//    var tutorialView: TutorialView!
//    let disposeBag = DisposeBag()
//    
//    init(_ viewController: UIViewController){
//        let tutorialView = TutorialView(frame: viewController.view.bounds)
//        viewController.view.addSubview(tutorialView)
//        self.tutorialView = tutorialView
////        UserDefaults.standard.set(<#T##value: Bool##Bool#>, forKey: <#T##String#>)
//    }
//}
//
//class InductionDeckCreateTutorial: Tutorial{
//    
//    override init(_ viewController: UIViewController) {
//        super.init(viewController)
//     
//        guard let viewController = viewController as? HomeViewController else{
//            return
//        }
//        
//        let card = viewController.cardButton
//        let deck = (viewController.cardView as! CardSelectView).deckButton
//        tutorialView.descriptionDirection = .up
//        tutorialView.append(card!, parent: viewController, description: "大プロの世界へようこそ\nまず、デッキを作成しバトルをしてみましょう。")
//        tutorialView.append(CGRect(x: 310, y: 74.5, width: 120, height: 200), hit: CGRect(x: 310, y: 74.5, width: 120, height: 200), description: "デッキ編成ボタンを押してみましょう")
//        print("222222222222222")
//        dump(card)
//        dump(card?.titleLabel)
//        dump(deck)
//        
//        card?.rx.tap.subscribe({ _ in
//            self.tutorialView.next()
//        }).disposed(by: disposeBag)
//        
//        deck?.rx.tap.subscribe{
//            self.tutorialView.next()
//        }.disposed(by: disposeBag)
//    }
//    
////    private func startFirst(){
////        let label = firstWelcome
////        let b = UIButton(frame: .zero)
////        b.setTitle("OK", for: .normal)
////        label.add(b)
////        label.didPressButtonHandler{
////            _, _ in
////            self.startSelectCardButton()
////        }
////        label.pop(at: homeViewController.view)
////    }
////
////    private func startSelectCardButton(){
////        let target = homeViewController.cardButton!
////        tutorial(target, label: selectCardButton, next: startDeckButton)
////    }
////
////    private func startDeckButton(){
////        let target = (homeViewController.cardView as! CardSelectView).deckButton!
////        tutorial(target, label: selectDeckButton, next: startCreateDeckButton)
////    }
////
////    private func startCreateDeckButton(){
////        let target = (homeViewController.cardView as! CardSelectView).deckButton!
////        tutorial(target, label: selectCreateDeckButton, next: {})
////    }
////
////    private func tutorial(_ target: UIButton, label: MMPopLabel, next: @escaping () -> ()) {
////        homeViewController.view.addSubview(label)
////        tutorial(homeViewController, target: target)
////        target.rx.tap.subscribe{ event in
////            next()
////            label.dismiss()
////        }.disposed(by: disposeBag)
////        label.pop(at: target)
////    }
////
////    var firstWelcome: MMPopLabel{
////        let text = "大プロの世界へようこそ。まずはデッキを作ってみましょう。"
////        let l = MMPopLabel(text: text)
////        return l!
////    }
////    var selectCardButton: MMPopLabel{
////        let text = "カードボタンを押してください"
////        let l = MMPopLabel(text: text)
////        return l!
////    }
////
////    var selectDeckButton: MMPopLabel{
////        let text = "デッキボタンを押してください"
////        let l = MMPopLabel(text: text)
////        return l!
////    }
////
////    var selectCreateDeckButton: MMPopLabel{
////        let text = "デッキ作成ボタンを押してください。"
////        let l = MMPopLabel(text: text)
////        return l!
////    }
//}
