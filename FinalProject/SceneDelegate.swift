//
//  SceneDelegate.swift
//  FinalProject
//
//  Created by sergey on 13.06.2023.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "isFirstLaunch") {
            defaults.set(true, forKey: "isFirstLaunch")
            DocumentsModel.createFolder(with: "cache")
        }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.backgroundColor = .systemBackground
        let storyboard = UIStoryboard(name: "My", bundle: .main)
        if let expireDate = UserDefaults.standard.value(forKey: "expireDate") as? Date {
            if expireDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                let vc = AuthViewController()
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
                return
            }
        }
        if let token = try? KeyChainService().getToken(identifier: "access_token") {
            AppDelegate.shared().token = token
            if let vc = storyboard.instantiateViewController(withIdentifier: "Friends") as? ViewController {
                let navVC = UINavigationController(rootViewController: vc)
                self.window?.rootViewController = navVC
                self.window?.makeKeyAndVisible()
                vc.profileModel.loadProfile(1)
            }
        } else {
            let vc = AuthViewController()
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
    }
}

