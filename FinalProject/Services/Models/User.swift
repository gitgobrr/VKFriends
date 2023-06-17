//
//  User.swift
//  FinalProject
//
//  Created by sergey on 16.06.2023.
//

import Foundation

struct FriendsGetResponse: Decodable {
    let response: FriendsGet
}

struct FriendsGet: Decodable {
    let count: Int
    let items: [User]
}

struct UsersGetResponse: Decodable {
    let response: [User]
}

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: URL
    let photoMax: URL
    
    let isClosed: Bool?
    let deactivated: String?
    let online: Int?
    
        
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case online
        case photo100 = "photo_100"
        case photoMax = "photo_max"
        case deactivated
        case isClosed = "is_closed"
    }
    
    var isCollapsed: Bool = false
    
    func name() -> String {
        return firstName+" "+lastName
    }
    
    func isOnline() -> Bool {
        return online == 1 ? true : false
    }
}
