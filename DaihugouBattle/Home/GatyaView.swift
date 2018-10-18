//
//  GatyaView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit

@IBDesignable class GatyaView: UINibView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var possessionGoldLabel: UILabel!
    @IBOutlet weak var possessionCrystal: UILabel!
    @IBOutlet weak var possessionTicket: UILabel!
    @IBOutlet weak var consumeGold: UILabel!
    @IBOutlet weak var consumeTicket: UILabel!
    @IBOutlet weak var consumeCrystal: UILabel!
    private var user: UserInfo!
    private var selectView: GatyaSheetSelectView!
    private var loadingView: LoadingView!
    private var gatyaTypes: [GatyaType]!
    private let gatya = GatyaServerAndLocal.shared
    var selectedGatyaId: Int{
        return typePicker.selectedRow(inComponent: 0)
    }
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUp()
    }
    
    deinit {
        UserInfo.shared.removeObserver("userInfo")
    }
    
    private func setUp(){
        gatyaTypes = []
        setUpPicker()
        setUpLabel()
    }
    
    private func setUpPicker(){
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    private func setUpLabel(){
        UserInfo.shared.update{ error in
            if let error = error{
                print(error)
            }
        }
        
        UserInfo.shared.addObserver("userInfo", self.updateUserInfo(_:))
    }
    
    func updateUserInfo(_ userInfo: UserInfo){
        possessionTicket.text = "\(userInfo.ticket)枚"
        possessionGoldLabel.text = "\(userInfo.gold)C"
        possessionCrystal.text = "\(userInfo.crystal)C"
    }
        
    
    @IBAction func buy(_ sender: UIButton) {
        guard let gatyaType: GatyaType = gatyaTypes[safe: selectedGatyaId] else{
            return
        }
        
        if selectView == nil{
            let space: CGFloat = 20
            let frame: CGRect = CGRect(x: space, y: 0, width: SSX - space * 2, height: SSY)
            selectView = GatyaSheetSelectView(frame: frame)
            selectView.alpha = 0.8
            selectView.tag = 99
            self.parentViewController()?.view.addSubview(selectView)
        }
        
        selectView.id = gatyaType.id
        switch sender.tag{
        case 1:
            selectView.segueIdentifier = "gatyaGold"
            selectView.consume = gatyaTypes[selectedGatyaId].consume.gold
            selectView.possession = UserInfo.shared.gold
            selectView.consumeType = "gold"
        case 2:
            selectView.segueIdentifier = "gatyaCrystal"
            selectView.consume = gatyaTypes[selectedGatyaId].consume.crystal
            selectView.possession = UserInfo.shared.crystal
            selectView.consumeType = "crystal"
        case 3:
            selectView.segueIdentifier = "gatyaTicket"
            selectView.consume = gatyaTypes[selectedGatyaId].consume.ticket
            selectView.possession = UserInfo.shared.ticket
            selectView.consumeType = "ticket"
        default:
            return
        }
        selectView.isHidden = true
        if selectView.max != 0{
            selectView.isHidden = false
            selectView.setUp()
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gatyaTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: pickerView.frame)
        label.text = gatyaTypes[row].name
        label.textColor = .white
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if gatyaTypes.outOfRange(row){
            return
        }
        let type = gatyaTypes[row]
        consumeGold.text    = "１パック\(type.consume.gold)ゴールド"
        consumeTicket.text  = "１パック\(type.consume.ticket)チケット"
        consumeCrystal.text = "１パック\(type.consume.crystal)クリスタル"
        imageView.image = DataRealm.get(imageNamed: type.imagePath)
    }
    
    func initGatyaType(){
        loadingView = LoadingView(frame: self.parentViewController()!.view.frame)
        self.parentViewController()!.view.addSubview(loadingView)
        gatya.getTypes{
            types, error in
            if let error = error{
                let errorAlart = UIAlertController(title: "サーバー通信エラー", message: nil, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "ホームに戻る", style: .default, handler: {
                    action in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let next = storyboard.instantiateViewController(withIdentifier: "home")
                    self.parentViewController()?.present(next, animated: true, completion: nil)
                })
                errorAlart.addAction(alertAction)
                errorAlart.message = error.localizedDescription
                print(error)
                self.parentViewController()?.present(errorAlart, animated: true, completion: {})
                return
            }
            self.gatyaTypes = types
            self.typePicker.reloadAllComponents()
            self.loadingView.isHidden = true
        }
    }
}
