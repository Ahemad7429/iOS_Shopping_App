//
//  AppDelegate.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 15/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        uiHalperAndConfigs()
        return true
    }

    func uiHalperAndConfigs() {
                initializePayPal()
        FirebaseApp.configure()
        
        IQKeyboardManager.shared().isEnabled = true
    }
        
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK:- Paypal
    private func initializePayPal() {
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction : "AdKeAzNPUkz18xUtf9K-hiuvl_oqjkqI7NW0AB1RF3JiiMzy2do6uK7SQhMluFg67GzmIcElXFORvN00", PayPalEnvironmentSandbox : "sb-keq9h3830106@personal.example.com"])
    }
}

