//
//  AppDelegate.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/20.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit
import NCMB
import Firebase
import Fabric
import Crashlytics
import HyperionCore

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NCMB.setApplicationKey(applicationkey, clientKey: clientkey)
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection10.bundle")?.load()
    
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}



///画面がタッチされた時にイベントを送る
class ApplicationSendTouchEvent: UIApplication{
    // respondersにtouchとeventが持つほとんどのプロパティは、恐らく欲しい値になっていない
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if TDPView.shared.superview == nil{
            //タッチ判定をさせないようにし、最前面に画面いっぱいに配置
            keyWindow?.addSubview(TDPView.shared)
            TDPView.shared.isUserInteractionEnabled = false
            TDPView.shared.frame = UIScreen.main.bounds
            TDPView.shared.layer.zPosition = CGFloat.leastNormalMagnitude
        }
        //パーティクルビューがまだ追加されていないなら最前面に追加する
        if let allTouches = event.allTouches{
            let touchBegan = allTouches.filter({ $0.phase == .began })
            let touchMoved = allTouches.filter({ $0.phase == .moved })
            let touchEnded = allTouches.filter({ $0.phase == .ended })
            let touchCancelled = allTouches.filter({ $0.phase == .cancelled })
            if !touchBegan.isEmpty{ TDPView.shared.touchesBegan(touchBegan, with: event) }
            if !touchMoved.isEmpty{ TDPView.shared.touchesMoved(touchMoved, with: event) }
            if !touchEnded.isEmpty{ TDPView.shared.touchesEnded(touchEnded, with: event) }
            if !touchCancelled.isEmpty{ TDPView.shared.touchesCancelled(touchCancelled, with: event) }
        }
    }
}
