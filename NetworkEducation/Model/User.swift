//
//  User.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 22.08.2023.
//

import Foundation

struct User: Codable {
      
    let id: Int
    let firstName: String
    let lastName: String
    let avatar: URL?
    
    static let example = User(
        id: 2,
        firstName: "Jane",
        lastName: "Flower",
        avatar: URL(string: "https://reqres.in/img/faces/7-image.jpg")!
    )
    
    init(id: Int, firstName: String, lastName: String, avatar: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
    }
    
    init(postUserQuery: PostUserQuery) {
        self.id = 0
        self.firstName = postUserQuery.firstName
        self.lastName = postUserQuery.lastName
        self.avatar = nil
    }
}
struct UsersQuery: Codable {
    let data: [User]
}

struct PostUserQuery: Codable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "name"
        case lastName = "job"
    }
}
