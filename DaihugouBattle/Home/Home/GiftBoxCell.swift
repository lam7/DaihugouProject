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
    private var giftItemInfo: GiftedItem!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var timeLimitDescriptionLabel: UILabel!
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
    
    func set(giftItemInfo: GiftedItem){
        self.giftItemInfo = giftItemInfo
        
        itemImageView.image   = DataRealm.get(imageNamed: giftItemInfo.imageNamed)
        nameLabel.text        = giftItemInfo.title
        countLabel.text       = "× \(giftItemInfo.count.description)"
        
        descriptionLabel.text = giftItemInfo.description
        timeLimitLabel.text = giftItemInfo.remainingTimeFormat()
        timeStampLabel.text = giftItemInfo.timeStampFormat()
        
        timeLimitLabel.isHidden = giftItemInfo.isReceived
        timeLimitDescriptionLabel.isHidden = giftItemInfo.isReceived
        gainButton.isHidden = giftItemInfo.isReceived
        
    }
}
