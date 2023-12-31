//
//  Response.swift
//  vkAPI
//
//  Created by sergey on 20.02.2018.
//  Copyright © 2018 sergey. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

protocol ProfileDelegate {
    func updateUser(_ user: User)
    func updateFriends()
    func displayError(_ errorMessage: String)
    func alert(_ message: String)
    func logOut()
}

class Profile {
    var user: User?
    
    var friends: [User] = []
    
    var onlineFriends: [User] {
        friends.filter { $0.isOnline() }
    }
    var offlineFriends: [User] {
        friends.filter { !$0.isOnline() }
    }
    
    var friendCount = 0
    
    var delegate: ProfileDelegate?
    
    let coreDataManager = CoreDataManager.shared
    
    //MARK: Methods for network calls
    
    func fetchData<T: Decodable>(_ endpoint: Endpoint<T>, completion: @escaping (T) -> Void) {
        AF.request(endpoint.url!).responseDecodable(of: T.self) { dataResponse in
            switch dataResponse.result {
            case .success(let decodable):
                return completion(decodable)
            case .failure(let afError):
                print(afError)
                if let vkError = VKAPIError.decode(data: dataResponse.data) {
                    if vkError.errorCode == .authError {
                        self.delegate?.alert(vkError.errorMsg)
                        self.delegate?.logOut()
                    }
                    self.delegate?.displayError(vkError.errorMsg)
                } else {
                    self.delegate?.displayError(afError.failureReason ?? afError.localizedDescription)
                    print("Printing body of failed response: ",String(data: dataResponse.data!, encoding: .utf8) ?? "no data",terminator: "\n")
                }
            }
        }
    }
    
    func loadProfile(_ id: Int) {
        if id == user?.id {
            if let user = user {
                self.delegate?.updateUser(user)
                self.delegate?.updateFriends()
            }
            return
        }
        friends = []
        fetchData(.getUser(by: id)) { (dataResponse) in
            guard let user = dataResponse.response.first else {
                self.delegate?.displayError("User not found")
                return
            }
            self.user = user
            self.delegate?.updateUser(user)
            self.loadFriends(user)
        }
    }
    
    func loadFriends(_ user: User) {
        fetchData(.getFriends(of: user, offset: friends.count)) { (dataResponse) in
            let fetchedFriends = dataResponse.response.items
            self.friendCount = dataResponse.response.count
            self.friends.append(contentsOf: fetchedFriends)
            self.delegate?.updateFriends()
        }
    }
    
    func loadImage(url: URL, completionHandler: ((UIImage?) -> Void)? = nil) {
        guard imageRequests[url] == nil else { return }
        do {
            let request = ImageURL.fetchRequest()
            request.predicate = .init(format: "url = %@", url as CVarArg)
            if let path = try CoreDataManager.shared.mainContext.fetch(request).first?.url {
                guard let data = DocumentsModel.read(from: path) else {
                    return
                }
                completionHandler?(UIImage(data: data))
                return
            }
        } catch {
            print(error.localizedDescription)
        }
        let request = AF.request(url).responseData { dataResponse in
            switch dataResponse.result {
            case .success(let data):
                // cache image
                DocumentsModel.write(data: data, with: url.lastPathComponent)
                // save url to core data
                let userImg = ImageURL(context: self.coreDataManager.mainContext)
                userImg.url = url.lastPathComponent
                self.coreDataManager.saveContext()
                // remove request
                self.imageRequests.removeValue(forKey: url)
                // call completion handler
                completionHandler?(UIImage(data: data))
            case .failure(let error):
                return print(error.failureReason ?? error.localizedDescription)
            }
        }
        imageRequests[url] = request
    }
    
    var imageRequests: [URL:DataRequest] = [:]
}
