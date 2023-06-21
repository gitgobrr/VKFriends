//
//  AuthViewController.swift
//  FinalProject
//
//  Created by sergey on 13.06.2023.
//

import UIKit
import WebKit

final class AuthViewController: UIViewController {
    private var webView = WKWebView()
    private let loginButton = UIButton()
    private let appID = "51675448"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let url = change?[NSKeyValueChangeKey.newKey] as? URL else { return }
        guard let fragment = URLComponents(url: url, resolvingAgainstBaseURL: true)?.fragment else { return }
        guard let queryItems = URLComponents(string: "?"+fragment)?.queryItems else { return }
        
        guard let key = queryItems.first(where: {$0.name == "access_token"})?.value else { return }
        if let expiresIn = queryItems.first(where: {$0.name == "expires_in"})?.value,
           let interval = TimeInterval(expiresIn) {
            let expireDate = Date.init(timeIntervalSinceNow: interval)
            UserDefaults.standard.set(expireDate, forKey: "expireDate")
        }
        guard let data = key.data(using: .utf8) else { return }
        do {
            try KeyChainService().insertToken(data, identifier: "access_token")
            AppDelegate.shared().token = key
            let storyboard = UIStoryboard(name: "My", bundle: .main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "Friends") as? ViewController {
                let navVC = UINavigationController(rootViewController: vc)
                self.view.window?.rootViewController = navVC
                vc.profileModel.loadProfile(1)
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            self.present(alert, animated: true)
        }
    }
    
    private func setupUI() {
        configureWebView()
        configureLoginButton()
    }
    
    private func configureLoginButton() {
        self.loginButton.setTitle("Login", for: .normal)
        self.loginButton.backgroundColor = .systemBlue
        self.view.addSubview(self.loginButton)
        self.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        NSLayoutConstraint.snapEqual(self.loginButton, self.view, [.centerX,.centerY])
    }
    
    private func configureWebView() {
        self.webView = WKWebView(frame: view.bounds)
        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.isHidden = true
        self.view.addSubview(webView)
        NSLayoutConstraint.snapToBounds(webView, self.view)
    }
    
    @objc
    private func login() {
        webView.isHidden = false
        loginButton.isHidden = true
        let app = UIApplication.shared
        guard let url = URL(string: API.vkAuthorizeURL) else {
            return
        }
        if app.canOpenURL(url) {
            guard var components = URLComponents(string: API.vkAuthorizeURL) else {
                return
            }
            let scope = ["friends","online"].joined(separator: ",")
            let params = ["scope":scope,"client_id":self.appID,"v":API.version]
            components.queryItems = params.map { .init(name: $0, value: $1) }
            guard let url = components.url else {
                return
            }
            app.open(url) { result in
                print("completion",result)
            }
        } else {
            guard let url = URL(string: "https://oauth.vk.com/authorize?revoke=1&response_type=token&display=mobile&scope=friends&v=\(API.version)&redirect_uri=https://oauth.vk.com/blank.html&client_id=\(appID)") else {
                return
            }
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
}

