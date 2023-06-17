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
    var token: String?
    static func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let fragment = URLComponents(url: url, resolvingAgainstBaseURL: true)?.fragment else { return false }
        guard let queryItems = URLComponents(string: "?"+fragment)?.queryItems else { return false }
        guard let key = queryItems.first(where: {$0.name == "access_token"})?.value else { return  false}
        let tag = "com.vk".data(using: .utf8)!
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecValueRef as String: key]
        let status = SecItemAdd(addquery as CFDictionary, nil)
        print(status, "add from app deleg")
        
        let storyboard = UIStoryboard(name: "My", bundle: .main)
        self.token = key
        window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "Friends")
        return true
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        let storyboard = UIStoryboard(name: "My", bundle: .main)
        if #unavailable(iOS 13) {
            self.window = UIWindow()
            self.window?.backgroundColor = .white
            if let token = try? KeyChainService().getToken(identifier: "access_token") {
                self.token = token
                let vc = storyboard.instantiateViewController(withIdentifier: "Friends")
                let navVC = UINavigationController(rootViewController: vc)
                self.window?.rootViewController = navVC
                self.window?.makeKeyAndVisible()
                return true
            } else {
                let vc = AuthViewController()
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
                return true
            }
        } else {
            self.window = UIWindow()
            self.window?.backgroundColor = .white
            if let token = try? KeyChainService().getToken(identifier: "access_token") {
                self.token = token
                let vc = storyboard.instantiateViewController(withIdentifier: "Friends")
                let navVC = UINavigationController(rootViewController: vc)
                self.window?.rootViewController = navVC
                self.window?.makeKeyAndVisible()
                return true
            } else {
                let vc = AuthViewController()
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
                return true
            }
        }
        
        return true
    }

}

