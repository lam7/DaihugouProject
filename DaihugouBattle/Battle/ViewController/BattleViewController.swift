//
//  BattleViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/04.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import FirebasePerformance


class BattleViewController: UIViewController, BattleFieldDelegate, TableDelegate{
    func changeCardStrength(_ cardStrength: CardStrength) {
        let owner = battleMaster.battleField.owner
        
        BattleViewController.asyncBlock.add{
            self.ownerView.arrangeHandAnimation(0.25, player: owner, completion: BattleViewController.asyncBlock.next)
            print("-----ChangeCardStrength-----")
            dump(cardStrength)
            print("-----------------------------")
        }
    }
    
    func changeSpotStatus(_ status: SpotStatus) {
        print("-----ChangeSpotStatus-----")
        dump(status)
        print("-----------------------------")
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    /// カード説明テキストビュー
    /// - parent: self.view
    @IBOutlet weak var characterStatusView: CharacterStatusDetailView!
    
    /// オーナーの全カード表示ビュー
    /// - parent: self.view
    @IBOutlet weak var ownerView: OwnerView!
    
    /// 敵の全カード表示ビュー
    /// - parent: self.view
    @IBOutlet weak var enemyView: EnemyView!
    
    /// spotのカード表示ビュー
    /// - parent: self.view
    @IBOutlet weak var spotView: SpotView!
    
    ///ターン開始時に表示される。どちらのターンかを表すビュー
    /// - parent: self.view
    @IBOutlet weak var turnLogoImageView: UIImageView!
    
    @IBOutlet weak var spotCollectionView: SpotCollectionView!
    
    @IBOutlet weak var skillView: BattleSkillView!{
        didSet{
            skillView.translatesAutoresizingMaskIntoConstraints = true
            skillView.frame.origin.y = -skillView.frame.height
        }
    }
//    var battleField: BattleField!
    var battleMaster: LocalBattleMaster!
    weak var touchView: UIView?
    static var asyncBlock: ControllAsyncBlock!
    
    var ownerCardViews: [CardView]!
    var enemyCardViews: [CardView]!
        
    ///オーナ側の手札のサイズ
    ///lazyを付けないとownerViewなどが初期化されていないときにこれを初期化しようとする
    private lazy var ownerHandSize = { () -> CGSize in
        let handView = self.ownerView.viewWithTag(10)!
        let height = handView.frame.height
        let width = height * 3 / 4
        return CGSize(width: width, height: height)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = DataRealm.get(imageNamed: "BattleBackgroundDoukutu.png")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let bgm = DefineServer.shared.value("battleBGM") as? String ?? "神臨 -しんりん-.mp3"
        ManageAudio.shared.addAudioFromRealm(bgm, audioType: .bgm)
        ManageAudio.shared.play(bgm)
        
        ManageAudio.shared.addAudioFromRealm("se_battle_attack.mp3", audioType: .se)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let bgm = DefineServer.shared.value("battleBGM") as? String ?? "神臨 -しんりん-.mp3"
        ManageAudio.shared.removeAudio(bgm)
        ManageAudio.shared.removeAudio("se_battle_attack.mp3")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareBattlePlayer{[weak self] in
            print("prepareFinish")
            guard let `self` = self else {
                return
            }
            self.prepareBattleView()
            //バトル開始
            self.battleMaster.gameStart({_ in})
        }
    }
    
    
    func prepareBattlePlayer(_ completion: @escaping () -> ()){
        
    }
    
    func prepareBattleView(){
        BattleViewController.asyncBlock = ControllAsyncBlock()
        self.battleMaster.delegate = self
        
        ownerView.chStatusView = self.characterStatusView
        enemyView.chStatusView = self.characterStatusView
        ownerView.skillView = self.skillView
        enemyView.skillView = self.skillView
        ownerView.death = self.deathOwner
        enemyView.death = self.deathEnemy
        
        //それぞれのviewにplayer, tableをセットする
        ownerCardViews = self.ownerView.set(battleMaster: battleMaster)
        enemyCardViews = self.enemyView.set(battleMaster: battleMaster)
        
        spotView.set(battleMaster: battleMaster)
        spotView.ownerCardViews = ownerCardViews
        spotView.enemyCardViews = enemyCardViews
        spotView.spotCollectionView = spotCollectionView
        
        battleMaster.battleField.table.delegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.removeAllSubviews()
    }
    
    @IBAction func touchUpSetting(_ sender: Any) {
        
    }
    
    @IBAction func touchUpPass(_ sender: Any) {
        //アニメーション中は処理をしない
        if BattleViewController.asyncBlock.isAsyncing{
            return
        }
        ownerView.clearPutDownCards()
        battleMaster.ownerPass({_ in})
//        battleField.pass()
    }
    
    @IBAction func touchUpPutDown(_ sender: Any) {
        //アニメーション中は処理をしない
        if BattleViewController.asyncBlock.isAsyncing{
            return
        }
        
        let cards = ownerView.putDownCards
        battleMaster.ownerPutDown(cards){
            [weak self] error in
            guard let `self` = self else {
                return
            }
            
            if let error = error{
                print(error)
                return
            }
        }
//        if !battleField.table.checkPutDown(cards){ return }
//        ownerView.clearPutDownCards()
//        battleField.owner.putDown(cards)
//        ownerView.removeFrame(cards)
//        battleField.turnEnd()
    }
    
    @IBAction func touchUpSpot(_ sender: Any) {
        spotCollectionView.isHidden = false
    }
    
    func deathOwner(){
        BattleViewController.asyncBlock.add{[weak self] in
            self?.appearDeathLabel{ label in
                label.text = "You Lose"
                label.textColor = .blue
            }
        }
    }
    
    func deathEnemy(){
        BattleViewController.asyncBlock.add{[weak self] in
            self?.appearDeathLabel{ label in
                label.text = "You Win"
                label.textColor = .red
            }
        }
    }
    
    private func appearDeathLabel(_ set: (_: UILabel)->()){
        let label = UILabel()
        self.view.addSubview(label)
        set(label)
        label.font = UIFont(name: "Times New Roman", size: 80)
        label.sizeToFit()
        label.snp.makeConstraints{ make in
            make.center.equalTo(self.view)
        }
        
        UIView.animate(withDuration: 0.8, animations: {
            label.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func startOwnerTurn() {
        BattleViewController.asyncBlock.add{[weak self] in
            guard let `self` = self else {
                return
            }
            //ターン開始のロゴを表示
            self.appearOwnerTurnLogo {
                BattleViewController.asyncBlock.next()
            }
        }
    }
    
    func endOwnerTurn() {
        //攻撃力をラベルに反映
    }
    
    func startEnemyTurn() {
        BattleViewController.asyncBlock.add{[weak self] in
            guard let `self` = self else {
                return
            }
            //ターン開始のロゴを表示
            self.appearEnemyTurnLogo {
                BattleViewController.asyncBlock.next()
            }
        }
    }
    
    func appearOwnerTurnLogo(_ completion: @escaping () -> ()){
        self.turnLogoImageView.image = DataRealm.get(imageNamed: "BattleLogo_YourTurn.png")
        self.turnLogoImageView.isHidden = false
        appearTurnLogo(completion)
    }
    
    func appearEnemyTurnLogo(_ completion: @escaping () -> ()){
        self.turnLogoImageView.image = DataRealm.get(imageNamed: "BattleLogo_EnemyTurn.png")
        self.turnLogoImageView.isHidden = false
        appearTurnLogo(completion)
    }
    
    private func appearTurnLogo(_ completion: @escaping () -> ()){
        UIView.animate(withDuration: 0.4, delay: 0.8, options: .curveEaseIn, animations: {
            [weak self] in
            guard let `self` = self else {
                return
            }
            self.turnLogoImageView.alpha = 0
        }, completion: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.turnLogoImageView.isHidden = true
            self.turnLogoImageView.alpha = 1
            completion()
        })
    }
    
    func endEnemyTurn() {
        //攻撃力をラベルに反映
    }
}

