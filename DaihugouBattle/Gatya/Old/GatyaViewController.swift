//
//  GatyaViewController.swift
//  Daihugou
//
//  Created by Main on 2017/06/06.
//  Copyright © 2017年 Main. All rights reserved.

import Foundation
import UIKit
import SpriteKit

/// 旧ガチャ
/// -TODO: いずれ消す
class GatyaViewController: UIViewController{
    var drawTimes: Int!
    var consumeType: String!
    var id: Int!
    private var errorAlart: UIAlertController!
    private var scene: GatyaScene!
    private var getCard: [Card]!
    private var selectedCard: Card?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    private let gatya = GatyaServer.shared
    private let drawCountOnceGatya = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loadingView: LoadingView2 = LoadingView2(frame: self.view.frame)
        self.view.addSubview(loadingView)
        let skView                    = self.view as! SKView
        skView.isMultipleTouchEnabled = false

        gatya.roll(id, times: drawTimes, consumeType: consumeType, completion: {
            cards, error in
            if let error = error{
                print(error)
                let errorAlart = UIAlertController(title: "エラー", message: nil, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "前の画面に戻る", style: .default, handler: {
                    action in
                    self.dismiss(animated: true, completion: nil)
                })
                errorAlart.addAction(alertAction)
                errorAlart.message = error.localizedDescription
                self.present(errorAlart, animated: true, completion: {})
                return
            }
            self.getCard = cards
            loadingView.removeFromSuperview()
            self.scene           = GatyaScene(size: skView.bounds.size)
            self.scene.scaleMode = .aspectFill
            skView.presentScene(self.scene)
            self.scene.set(card: self.takeOutCard())
            self.scene.buttonDelegate = self.next
            self.scene.characterDelegate = self.character
            
        })
    }
    
    private func takeOutCard()-> [Card]{
        var tmp:[Card] = []
        for i in (0..<drawCountOnceGatya).reversed(){
            tmp.append(getCard[i])
            getCard.remove(at: i)
        }
        return tmp
    }
    
    
    private func createErrorAlert(){
        errorAlart = UIAlertController(title: "エラー", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "前の画面に戻る", style: .default, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        })
        errorAlart.addAction(alertAction)
    }
    
    private func character(_ card: Card){
        characterDetailView.set(card: card)
        characterDetailView.isHidden = false
    }
    
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        print("tap")
        if !characterDetailView.isHidden{
            characterDetailView.isHidden = true
        }
    }
    
    /// ガチャの終わりならスキップボタンを非表示にし戻るボタンを表示する
    ///
    /// それ以外ならスキップボタンを非表示にしokボタンを表示する
    /// - Parameter isFinish: ガチャの終わりかどうか
    private func next(){
        let isFinish = getCard.isEmpty
        let button = isFinish ? backButton : okButton
        button?.alpha = 0
        button?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {button?.alpha = 1})
        UIView.animate(withDuration: 0.5, animations: {self.skipButton.alpha = 0}, completion: {
            _ in
            if isFinish{
                self.skipButton.removeFromSuperview()
            }else{
                self.skipButton.isHidden = true
            }
        })
    }
    
    @IBAction func okTouchUp(_ sender: Any) {
        skipButton.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {self.okButton.alpha = 0})
        UIView.animate(withDuration: 0.5, animations: {self.skipButton.alpha = 1})
        scene.touchOKButton {
            self.scene.set(card: self.takeOutCard())
        }
    }
}


//import Foundation
//import UIKit
//import SpriteKit
//
//public let drawCountOnceGatya = 8
//class GatyaViewController: UIViewController{
//    var drawTimes = 2
//    var consumeGold: Int = 0
//    var consumeCrystal: Int = 0
//    private var errorAlart: UIAlertController!
//    private var scene: GatyaScene!
//    var getCard: [Card]!
//    private var selectedCard: Card?
//    private let gatya = Gatya()
//    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var skipButton: UIButton!
//    @IBOutlet weak var okButton: UIButton!
//    @IBOutlet weak var characterDetailView: CharacterDetailView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let loadingView: LoadingView = LoadingView(frame: self.view.frame)
//
//        self.view.addSubview(loadingView)
//        let skView                    = self.view as! SKView
//        skView.isMultipleTouchEnabled = false
//
//        var list: [Card] = []
//        for i in 0..<52{
//            guard let card = CardList.get(i) else{
//                continue
//            }
//            list.append(card)
//        }
//        gatya.setEmissionCard(list)
//        getCard = drawCard(drawCountOnceGatya * drawTimes)
//        UserInfo.append(cards: getCard){ appendError in
//            if let appendError = appendError{
//                self.createErrorAlert()
//                self.errorAlart.message = "サーバー通信エラー カードを追加出来ませんでした \n \(appendError)"
//                return
//            }
//            let completion = {
//                loadingView.removeFromSuperview()
//                self.scene           = GatyaScene(size: skView.bounds.size)
//                self.scene.scaleMode = .aspectFill
//                skView.presentScene(self.scene)
//                self.scene.set(card: self.takeOutCard())
//                self.scene.buttonDelegate = self.next
//                self.scene.characterDelegate = self.character
//            }
//            if self.consumeGold > 0{
//                UserInfo.consume(gold: self.consumeGold){ error in
//                    if let error = error{
//                        print(error)
//                        var message: String = "サーバー通信エラー ゴールドを消費出来ませんでした"
//                        if let userInfoError = error as? UserInfoError {
//                            if userInfoError == .notEnough{
//                                message = "ゴールドが不足しています"
//                            }
//                        }
//                        self.createErrorAlert()
//                        self.errorAlart.message = message
//                        self.present(self.errorAlart, animated: true, completion: {})
//
//                        return
//                    }
//                    completion()
//                }
//            }else if self.consumeCrystal > 0{
//                UserInfo.consume(crystal: self.consumeCrystal){ error in
//                    if let error = error{
//                        print(error)
//                        var message: String = "サーバー通信エラー クリスタルを消費出来ませんでした"
//                        if let userInfoError = error as? UserInfoError {
//                            if userInfoError == .notEnough{
//                                message = "クリスタルが不足しています"
//                            }
//                        }
//                        self.createErrorAlert()
//                        self.errorAlart.message = message
//                        self.present(self.errorAlart, animated: true, completion: {})
//                        return
//                    }
//                    completion()
//                }
//            }else{
//                completion()
//            }
//        }
//    }
//
//    private func takeOutCard()-> [Card]{
//        var tmp:[Card] = []
//        for i in (0..<drawCountOnceGatya).reversed(){
//            tmp.append(getCard[i])
//            getCard.remove(at: i)
//        }
//        return tmp
//    }
//
//
//    private func createErrorAlert(){
//        errorAlart = UIAlertController(title: "エラー", message: nil, preferredStyle: .alert)
//        let alertAction = UIAlertAction(title: "前の画面に戻る", style: .default, handler: {
//            action in
//            self.dismiss(animated: true, completion: nil)
//        })
//        errorAlart.addAction(alertAction)
//    }
//
//    private func drawCard(_ n: Int)-> [Card]{
//        var getCard:[Card] = []
//        do{
//            getCard = try gatya.drawCard(n)
//        }catch{
//            createErrorAlert()
//            errorAlart.message = "カードが設置されていない"
//            self.present(errorAlart, animated: true, completion: nil)
//        }
//        return getCard
//    }
//
//    private func character(_ card: Card){
//        characterDetailView.set(card: card)
//        characterDetailView.isHidden = false
//    }
//
//
//    @IBAction func tap(_ sender: UITapGestureRecognizer) {
//        print("tap")
//        if !characterDetailView.isHidden{
//            characterDetailView.isHidden = true
//        }
//    }
//
//    /// ガチャの終わりならスキップボタンを非表示にし戻るボタンを表示する
//    ///
//    /// それ以外ならスキップボタンを非表示にしokボタンを表示する
//    /// - Parameter isFinish: ガチャの終わりかどうか
//    private func next(){
//        let isFinish = getCard.isEmpty
//        let button = isFinish ? backButton : okButton
//        button?.alpha = 0
//        button?.isHidden = false
//        UIView.animate(withDuration: 0.5, animations: {button?.alpha = 1})
//        UIView.animate(withDuration: 0.5, animations: {self.skipButton.alpha = 0}, completion: {
//            _ in
//            if isFinish{
//                self.skipButton.removeFromSuperview()
//            }else{
//                self.skipButton.isHidden = true
//            }
//        })
//    }
//
//    @IBAction func okTouchUp(_ sender: Any) {
//        skipButton.isHidden = false
//        UIView.animate(withDuration: 0.5, animations: {self.okButton.alpha = 0})
//        UIView.animate(withDuration: 0.5, animations: {self.skipButton.alpha = 1})
//        scene.touchOKButton {
//            self.scene.set(card: self.takeOutCard())
//        }
//    }
//}

