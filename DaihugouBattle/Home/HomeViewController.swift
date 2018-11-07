//
//  HomeViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/29.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Lottie

let SSX = UIScreen.main.bounds.size.width
let SSY = UIScreen.main.bounds.size.height
let CardSize: CGSize = CGSize(width: 600.cf, height: 800.cf)

class HomeViewController: UIViewController{
    weak var currentView: UIView!
    private var isFirst = true    
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var battleView: UIView!
    @IBOutlet weak var gatyaView: UIView!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var crystalLabel: EFCountingLabel!
    @IBOutlet weak var goldLabel: EFCountingLabel!
    @IBOutlet var viewButtons: [UIButton]!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var battleButton: UIButton!
    @IBOutlet weak var gatyaButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var backgroundLottieView: LOTAnimatedControl!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView(battleView)
        setUpLabel()
        UserInfo.shared.update{error in
            if let error = error{
                dump(error)
            }
        }
        crystalLabel.formatBlock = {
            $0.i.description + "C"
        }
        
        goldLabel.formatBlock = {
            $0.i.description + "G"
        }
        
        if let data = DataRealm.get(dataNamed: "the_final_frontier.json"){
            backgroundLottieView.translatesAutoresizingMaskIntoConstraints = true
            backgroundLottieView.animationView.setAnimation(data: data)
            backgroundLottieView.animationView.play()
            backgroundLottieView.animationView.loopAnimation = true
        }
        
        let tutorial = InductionDeckCreateTutorial(self)
        tutorial.tutorialView.start()
    }
    
    override func viewDidLayoutSubviews() {
        if isFirst{
            initView(battleView)
            isFirst = false
        }else{
            initView(nil)
        }        
    }
    override func viewWillAppear(_ animated: Bool) {
        let bgm = DefineServer.shared.value("homeBGM") as! String
        ManageAudio.shared.addAudioFromRealm("click.mp3", audioType: .se)
        ManageAudio.shared.addAudioFromRealm(bgm,audioType: .bgm)
        ManageAudio.shared.play(bgm)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let bgm = DefineServer.shared.value("homeBGM") as! String
        ManageAudio.shared.removeAudio(bgm)
        ManageAudio.shared.removeAudio("click.mp3")
    }
    
    private func setUpLabel(){
        UserInfo.shared.crystal
            .subscribe{
                guard let element = $0.element else{ return }
                self.crystalLabel.countFromCurrentValueTo(element.cf, withDuration: 0.8)
            }
            .disposed(by: disposeBag)
        
        UserInfo.shared.gold
            .subscribe{
                guard let element = $0.element else{ return }
                self.goldLabel.countFromCurrentValueTo(element.cf, withDuration: 0.8)
            }
            .disposed(by: disposeBag)
        
        UserInfo.shared.name
            .bind(to: rankLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func initView(_ st: UIView?){
        homeView.center.x = -SSX / 2
        cardView.center.x = -SSX / 2
        battleView.center.x = -SSX / 2
        gatyaView.center.x = -SSX / 2
        settingView.center.x = -SSX / 2
        guard let st = st else{
            self.currentView.center.x = SSX / 2
            return
        }
        self.currentView = st
        self.currentView.center.x = SSX / 2
    }
    
    
    
    private func moveView(_ view: UIView){
        if self.currentView == view{
            return
        }

        let currentView = self.currentView
        self.currentView = view
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            if currentView != nil{
                currentView!.center.x += SSX
            }
            view.center.x = SSX / 2
        }, completion: { _ in
            if currentView != nil{
            currentView!.center.x = -SSX / 2
            }
        })
    }
    
    @IBAction func touchUp(_ sender: UIButton){
        ManageAudio.shared.play("click.mp3")
        viewButtons.forEach{
            $0.isHighlighted = false
        }
        sender.isHighlighted = true
        (currentView as? SelectableView)?.clearView()
        switch sender.tag{
        case homeButton.tag: moveView(homeView)
        case cardButton.tag: moveView(cardView)
        case battleButton.tag: moveView(battleView)
        case gatyaButton.tag:
            (gatyaView as? GatyaSelectView)?.initGatyaType()
            moveView(gatyaView)
        case settingButton.tag: moveView(settingView)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "gatya"{
            print("prepareGatya")
            let controller = segue.destination as! GatyaRollViewController
            controller.gatya = sender as? Gatya
        }else if segue.identifier == "battle"{
            let controller = segue.destination as! BattleCPUViewController
            controller._ownerDeck = sender as? Deck
            controller._enemyDeck = sender as? Deck
        }else if segue.identifier == "deckForming"{
            let controller = segue.destination as! CreateDeckViewController
            let s = sender as? Deck
            controller.createDeck = CreateStandartDeck(deck: s)
        }
    }
}
