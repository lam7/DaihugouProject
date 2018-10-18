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
import LiquidFloatingActionButton

///一番最初の画面
class StartViewController: UIViewController, UIGestureRecognizerDelegate{
    @IBOutlet weak var particleView: ParticleView!
    @IBOutlet weak var applicationLabel: UILabel!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var menuButton: LiquidFloatingActionButton!
    private var isFirstTap = true
    var menuCells: [LiquidFloatingCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Error: iPodとかだと画面全体にパーティクルが表示されない
        particleView.presentParticles("StartViewParticle.sks")
        particleView.particles[0].position.y = -20
        particleView.fire()
        
        //アプリバージョンを表示
        applicationLabel.text = "Version \(Plist.version)\n"
        

        menuButton.delegate = self
        menuButton.dataSource = self
        menuButton.animateStyle = .down

        let cellFactory: (String, String) -> LiquidFloatingCell = { (iconName, name) in
            return LiquidFloatingLabelCell(icon: UIImage(named: iconName)!, name: name)
        }
        let cache = cellFactory("icon_cacheClear", "キャッシュクリア")
        menuCells.append(cache)
        cache.tap = {
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
        }
        
        let notice = cellFactory("icon_notice", "お知らせ")
        menuCells.append(notice)
        notice.tap = {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            print("お知らせ")
        }
        
//        let contact = cellFactory("icon_contact", "お問い合わせ")
//        menuCells.append(contact)
//        contact.tap = {
//            [weak self] _ in
//            guard let `self` = self else {
//                return
//            }
//            print("お問い合わせ")
//        }
        
        let test = cellFactory("icon_contact", "バトル")
        menuCells.append(test)
        test.tap = {
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
                    let ownerDeck = Deck(cards: cards, name: "オーナー")
                    let enemtDeck = Deck(cards: cards, name: "敵")
                    controller._enemyDeck = enemtDeck
                    controller._ownerDeck = ownerDeck
                    self.present(controller, animated: true, completion: nil)
                }}
            }

        }
        
        let test2 = cellFactory("icon_contact", "テスト")
        menuCells.append(test2)
        test2.tap = {
            [weak self] _ in
            guard let `self` = self else {
                return
            }
            SkillList.loadPropertyLocal()
            CardList.loadPropertyLocal()
            let v = DeckIndexBarGraph(frame: CGRect(x: 100, y: 100, width: 150, height: 100))
            v.indexCounts(from: CardList.CardDeck.test)
            self.view.addSubview(v)
//            SkillList.loadPropertyLocal()
//            CardList.loadPropertyLocal()
//            self.performSegue(withIdentifier: "test", sender: self)
        }
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
    
    @IBAction func touchUp(_ sender: UIButton){
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

extension StartViewController: LiquidFloatingActionButtonDelegate, LiquidFloatingActionButtonDataSource{
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return menuCells.count
    }
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell{
        return menuCells[index]
    }
}
