//
//  main.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/05.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>?.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(ApplicationSendTouchEvent.self),
    NSStringFromClass(AppDelegate.self)
)
