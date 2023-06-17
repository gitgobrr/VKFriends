//
//  Endpoint.swift
//  FinalProject
//
//  Created by sergey on 16.06.2023.
//

import Foundation

struct Endpoint<T> {
    let path: String
    let queryItems: [URLQueryItem]
}

extension Endpoint where T: Decodable {
    static func getUser(by id: Int) -> Endpoint<UsersGetResponse> {
        let fields = [API.Field](arrayLiteral: .firstName,.lastName,.photo100,.photoMax)
            .map { $0.rawValue }
            .joined(separator: ",")
        return Endpoint<UsersGetResponse>(
            path: API.usersGetPath,
            queryItems: [
                URLQueryItem(name: "user_ids", value: String(id)),
                URLQueryItem(name: "fields", value: fields),
                URLQueryItem(name: "v", value: API.version),
                URLQueryItem(name: "access_token", value: AppDelegate.shared().token)
            ]
        )
    }

    static func getFriends(of user: User) -> Endpoint<FriendsGetResponse> {
        let fields = [API.Field](arrayLiteral: .firstName,.lastName,.photo100,.photoMax,.online)
            .map { $0.rawValue }
            .joined(separator: ",")
        return Endpoint<FriendsGetResponse>(
            path: API.friendsGetPath,
            queryItems: [
                URLQueryItem(name: "user_id", value: String(user.id)),
                URLQueryItem(name: "fields", value: fields+",count"),
                URLQueryItem(name: "v", value: API.version),
                URLQueryItem(name: "access_token", value: AppDelegate.shared().token)
            ]
        )
    }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}
