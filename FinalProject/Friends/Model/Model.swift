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
}

class Profile {
    var user: User?
        // add count property and assign a value to it in request completion handler
    // do all computed properties
    var friends: [User] = []
    
    var onlineFriends: [User] {
        friends.filter { $0.isOnline() }
    }
    var offlineFriends: [User] {
        friends.filter { !$0.isOnline() }
    }
    
    var friendCount = 0
    
    var delegate: ProfileDelegate?
    
    //MARK: Methods for network calls
    
    func fetchData<T: Decodable>(_ endpoint: Endpoint<T>, completion: @escaping (T) -> Void) {
        AF.request(endpoint.url!).responseDecodable(of: T.self) { dataResponse in
            switch dataResponse.result {
            case .success(let decodable):
                return completion(decodable)
            case .failure(let afError):
                print(afError)
                if let vkError = VKAPIError.decode(data: dataResponse.data) {
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
//        onlineFriends = []
//        offlineFriends = []
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
//            self.onlineFriends.removeAll()
//            self.offlineFriends.removeAll()
//            for user in self.friends {
//                user.isOnline() ? self.onlineFriends.append(user) : self.offlineFriends.append(user)
//            }
            self.delegate?.updateFriends()
        }
    }
    
    func loadImage(url: URL, completionHandler: @escaping (UIImage?) -> Void) -> DataRequest? {
        do {
            let request = UserImage.fetchRequest()
            request.predicate = .init(format: "url = %@", url as CVarArg)
            if let coreItem = try CoreDataManager.shared.mainContext.fetch(request).first {
                completionHandler(coreItem.image)
                print("loaded from core data")
                return nil
            }
        } catch {
            print(error.localizedDescription)
        }
//        if let image = cache[url] {
//            completionHandler(image)
//            return nil
//        }
        let request = AF.request(url).responseData { dataResponse in
            switch dataResponse.result {
            case .success(let data):
                return completionHandler(UIImage(data: data))
            case .failure(let error):
                return print(error.failureReason ?? error.localizedDescription)
            }
        }
        return request
    }
    
    var imageRequests: [IndexPath:DataRequest] = [:]
//    var cache: [URL:UIImage] = [:]
}


/*
 init() {
         do {
             let request = UserImage.fetchRequest()
 //            request.predicate = .init(format: "url = %@", url as CVarArg)
             let coreItems = try CoreDataManager.shared.mainContext.fetch(request)
 //                completionHandler(coreItem.image)
                 print("loaded from core data")
             
             coreItems.forEach { userImage in
                 guard let url = userImage.url,
                       let image = userImage.image
                 else {
                     return
                 }
                 cache[url] = image
             }
         } catch {
             print(error.localizedDescription)
         }
 }
 
 var imageRequests: [IndexPath:DataRequest] = [:]
 var cache: [URL:UIImage] = [:]
 */
