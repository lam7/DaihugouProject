//
//  TDPView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/12/04.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
//class TDPViewController: UIViewController{
//    weak var tdpView: TDPView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        loadTDPView()
//    }
//
//    func loadTDPView(){
//        if self.tdpView != nil{
//            self.tdpView.removeSafelyFromSuperview()
//        }
//
//        guard let application = UIApplication.shared as? ApplicationSendTouchEvent else{
//            return
//        }
//        let tdpView = TDPView(frame: view.bounds)
//        view.insertSubview(tdpView, at: 0)
//        tdpView.layer.zPosition = Float.greatestFiniteMagnitude.cf
//        application.responders.append(WeakObject(object: tdpView))
//        self.tdpView = tdpView
//    }
//
//    override func viewWillDisappear(_ animated: Bool){
//        if tdpView != nil{
//            print("RemoveTDPView")
//            tdpView.removeFromSuperview()
//        }
//    }
//}
