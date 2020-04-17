//
//  AppDelegate.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/4.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  AppDelegate职责：
//      <iOS 13.0   全权处理App和UI的生命周期
//      >=   13.0   App的生命周期，新的Scene Session的生命周期

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        //为避免MQTT初始化后马上订阅，将单例初始化提前，订阅将在TagUtility中等获取tagList后执行
        print(MQTTService.sharedInstance.description())
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

