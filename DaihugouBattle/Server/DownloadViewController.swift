//
//  DownloadViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/24.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DownloadViewController: UIViewController{
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var imagePathLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    private var cards: [Card]!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cards = []
        let count: Int = CardList.cardsCount
        for _ in 0..<self.pageControl.numberOfPages{
            self.cards.append(CardList.get(count.random)!)
        }
        if !self.cards.isEmpty{
            self.characterDetailView.set(card: self.cards[0])
        }
        
        let downloadData = DownloadData()
        downloadData.lastDownloadedNamed
            .asDriver()
            .drive(imagePathLabel.rx.text)
            .disposed(by: disposeBag)
        downloadData.countDownloaded
            .asDriver()
            .map({ $0.description + "/" + downloadData.countDownloadDatas.description})
            .drive(progressLabel.rx.text)
            .disposed(by: disposeBag)
        downloadData.countDownloaded
            .asDriver()
            .map({ $0.f / downloadData.countDownloadDatas.f })
            .drive(progressView.rx.progress)
            .disposed(by: disposeBag)
        
        downloadData.setUpServer{
            [weak self] error in
            guard let `self` = self else {
                return
            }
            if let error = error{
                self.alert(error, actions: self.BackAlertAction)
                return
            }
            
            do{
                try downloadData.erased()
            }catch let error{
                self.alert(error, actions: self.BackAlertAction)
                return
            }
            
            downloadData.download(error: {
                error in
                self.alert(error, actions: self.BackAlertAction)
            }, completion: {
                do{
                    try downloadData.check()
                }catch let error{
                    self.alert(error, actions: self.BackAlertAction)
                    return
                }
                self.updateImageVersion()
                self.performSegue(withIdentifier: "home", sender: self)
            })
        }
    }
    
    private func updateImageVersion(){
        let version = ImageVersion.getLatestVersion()
        let userDefault = UserDefaults.standard
        userDefault.set(version, forKey: "imageVersion")
        userDefault.synchronize()
    }
    
    @IBAction func pageControl(_ sender: UIPageControl) {
        if !cards.inRange(sender.currentPage){
            return
        }
        let card = cards[sender.currentPage]
        characterDetailView.set(card: card)
    }
}
