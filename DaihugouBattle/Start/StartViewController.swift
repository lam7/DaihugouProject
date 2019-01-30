//
//  StartViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/07.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import Chameleon
import RxSwift
import Floaty
import FirebaseAuth

///一番最初の画面
class StartViewController: UIViewController, UIGestureRecognizerDelegate{
    @IBOutlet weak var particleView: ParticleView!
    @IBOutlet weak var applicationLabel: UILabel!
    @IBOutlet weak var tapLabel: UILabel!
    weak var menuButton: Floaty!
    private var isFirstTap = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Error: iPodとかだと画面全体にパーティクルが表示されない
        particleView.presentParticles("StartViewParticle.sks")
        particleView.particles[0].position.y = -20
        particleView.fire()
        
        //アプリバージョンを表示
        applicationLabel.text = "Version \(Plist.version)\n"
        
        let s: CGFloat = 60
        let m: CGFloat = 10
        let menuButton = Floaty(frame: CGRect(x: view.frame.maxX - s - m, y: m, width: s, height: s))
        view.addSubview(menuButton)
        self.menuButton = menuButton
        menuButton.verticalDirection = .down
        menuButton.addItem("キャッシュクリア", icon: UIImage(named: "icon_cacheClear")!, handler: {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            //キャッシュクリアビューの作成
            let dx: CGFloat = 50.0
            let dy: CGFloat = 20.0
            let frame = CGRect(x: dx, y: dy, width: self.view.frame.width - dx * 2, height: self.view.frame.height - dy * 2)
            let cacheView = CacheClearView(frame: frame)
            self.view.addSubview(cacheView)
            UIView.animateOpenWindow(cacheView)
        })
        
        menuButton.addItem("お知らせ", icon: UIImage(named: "icon_notice")!, handler: {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            print("お知らせ")
        })
        
        menuButton.addItem("お問い合わせ", icon: UIImage(named: "icon_contact")!, handler: {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            print("お問い合わせ")
        })
        
        menuButton.addItem(title: "バトル", handler: {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            
            DefineServer.shared.loadProperty{ _ in
                SkillList.loadProperty{ _ in
                    CardList.loadProperty{ _ in
                        //                        SkillList.loadPropertyLocal()
                        //                            CardList.loadPropertyLocal()
                        let storyboard = UIStoryboard(name: "Battle", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "battleCPU") as! BattleCPUViewController
                        let cards = [
                            CardList.get(id: 1),CardList.get(id: 2),CardList.get(id: 3),CardList.get(id: 4),
                            CardList.get(id: 5),CardList.get(id: 6),CardList.get(id: 7),CardList.get(id: 8),
                            CardList.get(id: 9),CardList.get(id: 10),CardList.get(id: 1),CardList.get(id: 2),
                            CardList.get(id: 3),CardList.get(id: 4),CardList.get(id: 5),CardList.get(id: 6),
                            CardList.get(id: 7),CardList.get(id: 8),CardList.get(id: 9),CardList.get(id: 10),
                            CardList.get(id: 1),CardList.get(id: 2),CardList.get(id: 3),CardList.get(id: 4),
                            CardList.get(id: 5),CardList.get(id: 6),CardList.get(id: 7),CardList.get(id: 8),
                            CardList.get(id: 9),CardList.get(id: 10),CardList.get(id: 1),CardList.get(id: 2),
                            CardList.get(id: 3),CardList.get(id: 4),CardList.get(id: 5),CardList.get(id: 6),
                            CardList.get(id: 7),CardList.get(id: 8),CardList.get(id: 9),CardList.get(id: 10),
                            //                CardList.get(id: 9),CardList.get(id: 10),CardList.get(id: 11),CardList.get(id: 12),
                            //                CardList.get(id: 13),CardList.get(id: 14),CardList.get(id: 15),CardList.get(id: 16),
                            //                CardList.get(id: 17),CardList.get(id: 18),CardList.get(id: 19),CardList.get(id: 20),
                            //                CardList.get(id: 21),CardList.get(id: 22),CardList.get(id: 23),CardList.get(id: 24),
                            //                CardList.get(id: 25),CardList.get(id: 26),CardList.get(id: 27),CardList.get(id: 28),
                            //                CardList.get(id: 29),CardList.get(id: 30),CardList.get(id: 31),CardList.get(id: 32),
                            //                CardList.get(id: 33),CardList.get(id: 34),CardList.get(id: 35),CardList.get(id: 36),
                            //                CardList.get(id: 37),CardList.get(id: 38),CardList.get(id: 39),CardList.get(id: 40),
                            ].compactMap({ $0 })
                        let ownerDeck = Deck(cards: cards)
                        let enemtDeck = Deck(cards: cards)
                        controller._enemyDeck = enemtDeck
                        controller._ownerDeck = ownerDeck
                        self.present(controller, animated: true, completion: nil)
                    }}
            }
        })
        
        menuButton.addItem(title: "お問い合わせ", handler: {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            let tutorial = TutorialView(frame: self.view.bounds)
            self.view.addSubview(tutorial)
            tutorial.append(self.menuButton, description: "ボタンを押して")
            tutorial.descriptionDirection = .left
            tutorial.start()
            //            SkillList.loadPropertyLocal()
            //            CardList.loadPropertyLocal()
            //            self.performSegue(withIdentifier: "test", sender: self)
        })
           }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ManageAudio.shared.addAudioFromLocal("勇者たちのララバイ.mp3",audioType: .bgm)
        ManageAudio.shared.play("勇者たちのララバイ.mp3")
        
        //ラベルを点滅させる
        UIView.animateKeyframes(withDuration: 1.8, delay: 0, options: [UIView.KeyframeAnimationOptions.repeat, UIView.KeyframeAnimationOptions.autoreverse], animations: {
            self.tapLabel.alpha = 0.1
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ManageAudio.shared.removeAudio("勇者たちのララバイ.mp3")
    }
    
    @IBAction func tap(_ sender: Any){
        login()
    }
    
    private func login(){
        //二度タップ防止
        if !isFirstTap{ return }
        isFirstTap = false
        print("tap")
        
        let dispatchGroup = DispatchGroup()
        let completion: (_ error: Error?) -> () = {
            [weak self] error in
            guard let `self` = self else {
                return
            }
            if let error = error{
                self.isFirstTap = true
                self.present(error, completion: nil)
                return
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        CardList.loadProperty(completion: completion)
        
        dispatchGroup.enter()
        UserLogin.login(completion: completion)
        
        dispatchGroup.enter()
        DefineServer.shared.loadProperty(completion)
        
        dispatchGroup.notify(queue: .main){
             [weak self] in
            guard let `self` = self else {
                return
            }
            self.isFirstTap = true
            let isLatest = ImageVersion.isLatest()
            if isLatest{
                self.performSegue(withIdentifier: "home", sender: self)
            }else{
                self.performSegue(withIdentifier: "download", sender: self)
            }
        }
    }
    
    func present(_ error: Error, completion: (() -> ())?){
        let errorAlart: UIAlertController! = UIAlertController(title: "サーバー通信エラー", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlart.addAction(alertAction)
        errorAlart.message = error.localizedDescription
        self.present(errorAlart, animated: true, completion: completion)
    }
    
    func present(_ error: Error, title: String, completion: (() -> ())?){
        let errorAlart = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlart.addAction(alertAction)
        errorAlart.message = error.localizedDescription
        self.present(errorAlart, animated: true, completion: completion)
    }
    
}
