//
//  AppDelegate.swift
//  FinalProject
//
//  Created by sergey on 13.06.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #unavailable(iOS 13) {
            self.window = UIWindow()
            self.window?.backgroundColor = .white
            let vc = ViewController()
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    
}

