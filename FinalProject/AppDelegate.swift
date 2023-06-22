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
        guard let data = key.data(using: .utf8) else { return false }
        if let expiresIn = queryItems.first(where: {$0.name == "expires_in"})?.value,
           let interval = TimeInterval(expiresIn) {
            let expireDate = Date.init(timeIntervalSinceNow: interval)
            UserDefaults.standard.set(expireDate, forKey: "expireDate")
        }
        try? KeyChainService().insertToken(data, identifier: "access_token")
        let storyboard = UIStoryboard(name: "My", bundle: .main)
        self.token = key
        if let vc = storyboard.instantiateViewController(withIdentifier: "Friends") as? ViewController {
            window?.rootViewController = vc
            vc.profileModel.loadProfile(1)
        }
        return true
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "isFirstLaunch") {
            defaults.set(true, forKey: "isFirstLaunch")
            DocumentsModel.createFolder(with: "cache")
        }
        let storyboard = UIStoryboard(name: "My", bundle: .main)
        if #unavailable(iOS 13) {
            self.window = UIWindow()
            self.window?.backgroundColor = .white
            if let expireDate = UserDefaults.standard.value(forKey: "expireDate") as? Date {
                if expireDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                    let vc = AuthViewController()
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }
            }
            if let token = try? KeyChainService().getToken(identifier: "access_token") {
                self.token = token
                if let vc = storyboard.instantiateViewController(withIdentifier: "Friends") as? ViewController {
                    window?.rootViewController = vc
                    vc.profileModel.loadProfile(1)
                    let navVC = UINavigationController(rootViewController: vc)
                    self.window?.rootViewController = navVC
                    self.window?.makeKeyAndVisible()
                    return true
                }
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

