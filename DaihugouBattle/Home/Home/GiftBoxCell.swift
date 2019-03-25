//
//  GiftBoxCell.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/08.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class GiftBoxCell: UITableViewCell{
    weak var view: UIView!
    var gainBlock: ((_: [(String,GiftedItemInfo)]) -> ())?
    private var giftItemInfo: (String, GiftedItemInfo)!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var gainButton: UIButton!
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        loadNib()
    }
    
    func loadNib() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        return Bundle(for: type(of: self)).loadNibNamed("GiftBoxCell", owner: self, options: nil)?.first as! UIView
    }
    
    func set(giftItemInfo: (String, GiftedItemInfo)){
        self.giftItemInfo = giftItemInfo
        let giftItemInfo: GiftedItemInfo = giftItemInfo.1
        
        itemImageView.image   = DataRealm.get(imageNamed: giftItemInfo.imageNamed)
        nameLabel.text        = GiftedItemList.name(giftItemInfo)
        countLabel.text       = "× \(giftItemInfo.count.description)"
        descriptionLabel.text = giftItemInfo.description
        
        let f                   = DateFormatter()
        
        f.dateStyle             = DateFormatter.Style.medium
        f.timeStyle             = DateFormatter.Style.short
        f.locale                = Locale(identifier: "ja_JP")
        timeStampLabel.text     = f.string(from: giftItemInfo.timeStamp)
        let now: Date           = Date(timeIntervalSinceNow: 0)
        var dTime: TimeInterval = giftItemInfo.timeLimit.timeIntervalSince(now)
        if dTime < 0{
            timeLimitLabel.text = "時間切れ"
            return
        }
        let dayTime: Int  = 60 * 60 * 24
        let day: Int      = dTime.i / dayTime
        dTime -= Double(day *  dayTime)
        let hourTime: Int = 60 * 60
        let hour: Int     = dTime.i / hourTime
        dTime -= Double(hour * hourTime)
        let minute: Int   = dTime.i / 60
        if day != 0{
            timeLimitLabel.text = "あと\(day)日"
            return
        }
        if hour != 0{
            timeLimitLabel.text = "あと\(hour)時間"
            return
        }
        timeLimitLabel.text = "あと\(minute)分"
    }
    
    @IBAction func touchUpGain(_ sender: UIButton){
        gainBlock?([giftItemInfo])
    }
}
