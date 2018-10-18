//
//  DownloadViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/24.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

class DownloadViewController: UIViewController{
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var imagePathLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    private var cards: [Card]!
    
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
        
        let download: DownloadData = DownloadData()
        download.setUpRealm()
        download.setUpServer({
            [weak self](setUperror: Error?) in
            guard let `self` = self else {
                return
            }
            if let error = setUperror{
                print(error)
                self.dismiss(animated: true, completion: nil)
                return
            }
            do{
                try download.erased()
            }catch let erasedError{
                print(erasedError)
                return
            }
            download.download(progress: {
                [weak self](path: String, progress: Int, downloadError: Error?) in
                guard let `self` = self else {
                    return
                }
                if let error = downloadError{
                    print("downloadError " + path + progress.description)
                    print(error)
                    self.dismiss(animated: true, completion: nil)
                }
                self.imagePathLabel.text = path
                self.progressLabel.text = progress.description + " / " + download.downloadMax.description
                self.progressView.setProgress(Float(progress) / download.downloadMax, animated: true)
                }, completion: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.progressLabel.text = "check"
                download.check()
                download.download(progress: {
                    (path: String, progress: Int, downloadError: Error?) in
                    if let error = downloadError{
                        print("downloadError " + progress.description)
                        print(error)
                    }
                    self.imagePathLabel.text = path
                    self.progressLabel.text = progress.description + " / " + download.downloadMax.description
                    self.progressView.setProgress(Float(progress) / download.downloadMax, animated: true)
                }, completion: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    let version = ImageVersion.getLatestVersion()
                    self.imagePathLabel.text = "fin"
                    print("fin")
                    print(version)
                    let userDefault = UserDefaults.standard
                    userDefault.set(version, forKey: "imageVersion")
                    userDefault.synchronize()
                    self.performSegue(withIdentifier: "home", sender: self)
                })
            })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    @IBAction func pageControl(_ sender: UIPageControl) {
        if !cards.inRange(sender.currentPage){
            return
        }
        let card = cards[sender.currentPage]
        characterDetailView.set(card: card)
    }
}
