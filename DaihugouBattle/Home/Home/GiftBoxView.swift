//
//  GiftBoxView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/08.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit



class GiftBoxView: UINibView, UITableViewDelegate, UITableViewDataSource{
//    @IBOutlet weak var segmentedHistory: UISegmentedControl!
    @IBOutlet weak var giftTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectiveButton: UIButton!
    
    var giftItemInfos: [(String, GiftItemInfo)] = []
    @IBAction func touchUpClose(_ sender: UIButton){
        self.removeFromSuperview()
    }
    
    @IBAction func touchUpCollective(_ sender: UIButton){
        var infos: [(String, GiftItemInfo)] = []
        for i in 0..<20{
            if let info = giftItemInfos[safe: i]{
                infos.append(info)
            }
        }
        gain(infos)
    }
    
    @IBAction func changed(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            updateInfosReceived()
        }else{
            updateInfosHistory()
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        giftTableView.register(GiftBoxCell.self, forCellReuseIdentifier: "giftBoxCell")
        activityIndicator.transform.scaledBy(x: 10, y: 10)
    }
    
    func gain(_ giftItemInfos: [(String, GiftItemInfo)]){
        activityIndicator.isHidden = false
        GiftedItemList.effect(giftItemInfos.map{ $0.1 }){ error in
            if let error = error{
                let alert = UIAlertController(title: "通信エラー", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                    self.removeFromSuperview()
                })
                alert.addAction(action)
                self.parentViewController()?.present(alert, animated: true, completion: nil)
            }
            UserInfo.shared.delete(giftItem: giftItemInfos.map{ $0.0 }){ error in
                if let error = error{
                    let alert = UIAlertController(title: "通信エラー", message: error.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                        self.removeFromSuperview()
                    })
                    alert.addAction(action)
                    self.parentViewController()?.present(alert, animated: true, completion: nil)
                }
                self.updateInfosReceived()
            }
        }
    }
    
    func present(_ error: Error?)-> Bool{
        if let error = error{
            let alert = UIAlertController(title: "通信エラー", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.removeFromSuperview()
            })
            alert.addAction(action)
            self.parentViewController()?.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    func updateInfosReceived(){
        activityIndicator.isHidden = false
        GiftBox.receivedItems(){
            [weak self]error, infos in
            guard let `self` = self else {
                return
            }
            if self.present(error){
                return
            }
            self.collectiveButton.isEnabled = true
            self.giftItemInfos = infos
            self.giftTableView.reloadData()
            self.activityIndicator.isHidden = true
        }
    }
    
    func updateInfosHistory(){
        activityIndicator.isHidden = false
        GiftBox.historyItems(){
            [weak self]error, infos in
            guard let `self` = self else {
                return
            }
            if self.present(error){
                return
            }
            self.collectiveButton.isEnabled = false
            self.giftItemInfos = infos
            self.giftTableView.reloadData()
            self.activityIndicator.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return giftItemInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftBoxCell", for: indexPath) as! GiftBoxCell
        guard let info = giftItemInfos[safe: indexPath.row] else{
            print("GiftBoxView: tableView giftItemInfos not contains row at \(indexPath.row)")
            return cell
        }
        cell.set(giftItemInfo: info)
        if segmentedControl.selectedSegmentIndex == 0{
            cell.gainButton.isHidden = false
            cell.gainBlock = gain(_:)
        }else{
            cell.gainButton.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func removeFromSuperview() {
        UIView.animateCloseWindow(self){
            super.removeFromSuperview()
        }
    }
}
