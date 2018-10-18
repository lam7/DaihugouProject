//
//  WeakObject.swift
//  DaihugouBattle
//
//  Created by Main on 2018/07/11.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation

struct WeakObject<T: AnyObject> {
    weak var object: T?
    
    init(object: T?){
        self.object = object
    }
}
