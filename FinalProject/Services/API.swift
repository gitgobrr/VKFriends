//
//  API.swift
//  FinalProject
//
//  Created by sergey on 16.06.2023.
//

import Foundation

enum API {
    static let vkAuthorizeURL = "vkauthorize://authorize"
    static let scheme = "https"
    static let host = "api.vk.com"
    static let oauthHost = "oauth.vk.com"
    static let usersGetPath = "/method/users.get"
    static let friendsGetPath = "/method/friends.get"
    static let oauthPath = "/authorize"
    static let version = "5.131"
    
    enum Field: String {
        case firstName = "first_name"
        case lastName = "last_name"
        case online = "online"
        case photo100 = "photo_100"
        case photoMax = "photo_max"
        case count
    }
    
    enum Scope: String {
        case friends
        case offline
    }
}

struct VKAPIError: Error, Decodable {
    let errorMsg: String
    
    static func decode(data: Data?) -> Self? {
        guard let data = data else { return nil }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let json = try? decoder.decode([String:VKAPIError].self, from: data), let vkError = json["error"] else {
            return nil
        }
        return vkError
    }
}
