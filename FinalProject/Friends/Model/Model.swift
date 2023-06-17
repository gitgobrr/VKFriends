//
//  Response.swift
//  vkAPI
//
//  Created by sergey on 20.02.2018.
//  Copyright © 2018 sergey. All rights reserved.
//

import Foundation
import Alamofire

protocol ProfileDelegate {
    func updateUser(_ user: User)
    func updateFriends(_ friends: [User])
    func displayError(_ errorMessage: String)
}

class Profile {
    var user: User?
    var friends: [User] = []
    var onlineFriends: [User] = []
    var offlineFriends: [User] = []
    
    var delegate: ProfileDelegate?
    
    //MARK: Methods for network calls
    
    func fetchData<T: Decodable>(_ endpoint: Endpoint<T>, completion: @escaping (AFDataResponse<T>) -> Void) {
        AF.request(endpoint.url!).responseDecodable(completionHandler: completion)
    }
    
    func loadProfile(_ id: Int) {
        if id == user?.id { return }
        friends = []
        onlineFriends = []
        offlineFriends = []
        fetchData(.getUser(by: id)) { response in
            switch response.result {
            case .success(let response):
                guard let user = response.response.first else {
                    self.delegate?.displayError("User not found")
                    return
                }
                self.user = user
                self.delegate?.updateUser(user)
            case .failure:
                self.delegate?.displayError("user is deactivated")
                return
            }
        }
    }
    
    func loadFriends(of user: User) {
        fetchData(.getFriends(of: user)) { response in
            switch response.result {
            case .success(let response):
                self.friends = response.response.items
                self.onlineFriends.removeAll()
                self.offlineFriends.removeAll()
                for user in self.friends {
                    user.isOnline() ? self.onlineFriends.append(user) : self.offlineFriends.append(user)
                }
                self.delegate?.updateFriends(response.response.items)
            case .failure(let error):
                self.delegate?.displayError(error.localizedDescription)
                return
            }
        }
    }
    
    func loadImage(url: URL, completionHandler: @escaping (Data) -> Void) {
        AF.request(url).responseData(queue: .main) { data in
            switch data.result {
            case .success(let image):
                completionHandler(image)
            case .failure(let error):
                self.delegate?.displayError(error.localizedDescription)
                return
            }
        }
    }
    
}

