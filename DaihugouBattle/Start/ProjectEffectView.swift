//
//  ProjectEffectView.swift
//  DaihugouBattle
//
//  Created by main on 2019/02/11.
//  Copyright © 2019 Main. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import GlitchLabel

class ProjectEffectView: TapableView{
    weak var label: GlitchLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let label = GlitchLabel()
        self.addSubview(label)
        self.label = label
        label.snp.makeConstraints{ make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
        label.blendMode = .multiply
        label.text = "S_Project"
        label.font = UIFont(name: "Zapfino", size: 50)
    }
    
    override func tap(_ sender: UITapGestureRecognizer) {
        self.removeSafelyFromSuperview()
    }
    
    func fadeoutAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){[weak self] in
            UIView.animate(withDuration: 0.5, animations: {
                self?.alpha = 0
            }, completion: { [weak self] _ in
                self?.removeSafelyFromSuperview()
            })
        }
    }
}
