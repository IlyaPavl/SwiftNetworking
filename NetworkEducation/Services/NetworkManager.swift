//
//  NetworkManager.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 22.08.2023.
//

import Foundation
import Alamofire


final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchUsers(completion: @escaping (Result<[User], AFError>) -> Void) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        AF.request(Link.allUsers.url)
            .validate()
            .responseDecodable(of: UsersQuery.self, decoder: decoder) { dataResponse in
                switch dataResponse.result {
                    
                case .success(let usersQuery):
                    completion(.success(usersQuery.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    
    func post(_ user: User, completion: @escaping (Result<PostUserQuery, AFError>) -> Void) {
 
    }
    
    func deleteUser(with id: Int, completion: @escaping (Bool) -> Void) {

    }

}


// MARK: - Link

extension NetworkManager {
    enum Link {
        case allUsers
        case withNoData
        case withDecodingErrors
        case withNoUsers
        case singleUser
        
        var url: URL {
            switch self {
            case .allUsers:
                return URL(string: "https://reqres.in/api/users/?delay=1")!
            case .withNoData:
                return URL(string: "https://reqres.int/api/users")!
            case .withDecodingErrors:
                return URL(string: "https://reqres.in/api/users/3?delay=1")!
            case .withNoUsers:
                return URL(string: "https://reqres.in/api/users/?delay=1&page=3")!
            case .singleUser:
                return URL(string: "https://reqres.in/api/users")!
            }
        }
    }
}
