//
//  NetworkManager.swift
//  NetworkEducation
//
//  Created by Ilya Pavlov on 22.08.2023.
//

import Foundation

enum NetworkError: Error {
    case decodingError
    case noData
    case noUsers
    case invalidSC
    case deleteError
    
    var title: String {
        switch self {
        case .decodingError:
            return "Can't decode received data"
        case .noData:
            return "Can't fetch data"
        case .noUsers:
            return "No users to get from API"
        case .invalidSC:
            return "Invalid SC"
        case .deleteError:
            return "Can't delete user"
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchAvatar(from url: URL, completion: @escaping(Data) -> Void) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            
            DispatchQueue.main.async {
                completion(imageData)
            }
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: Link.allUsers.url) { data, response, error in
            
            // проверяем номер ответа по url
            guard let data, let response = response as? HTTPURLResponse else {
                print(error?.localizedDescription ?? "No error description")
                sendFailure(with: .noData)
                return
            }
            
            /* проверяем, есть ли дата в ответе
             guard let data else {
             print(error?.localizedDescription ?? "No description")
             sendFailure(with: .noData)
             return
             }
             */
            
            // проверяем статус ошибки в response
            if (200...299).contains(response.statusCode) {
                
                // деокдируем данные
                let decoder = JSONDecoder()
                // конвертируем из snakecase
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let userQuery = try decoder.decode(UsersQuery.self, from: data)
                    DispatchQueue.main.async {
                        if userQuery.data.count == 0 {
                            sendFailure(with: .noData)
                            return
                        }
                        completion(.success(userQuery.data))
                    }
                } catch {
                    sendFailure(with: .decodingError)
                }
            }
            
            func sendFailure(with error: NetworkError) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
    
    
    // более новый способ получения данных пользователей с помощью async throws
    func fetchUsers() async throws -> Result<[User], NetworkError> {
        let (data, response) = try await URLSession.shared.data(from: Link.allUsers.url)

        guard let response = response as? HTTPURLResponse else {
            return .failure(.noData)
        }
        
        if (200...299).contains(response.statusCode) {
            // деокдируем данные
            let decoder = JSONDecoder()
            // конвертируем из snakecase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let userQuery = try decoder.decode(UsersQuery.self, from: data)
                if userQuery.data.count == 0 {
                    return .failure(.noUsers)
                }
                return .success(userQuery.data)
            } catch {
                return .failure(.decodingError)
            }
        } else {
            return .failure(.invalidSC)
        }
    }
    
    func post(_ user: User, completion: @escaping (Result<PostUserQuery, NetworkError>) -> Void) {
        var request = URLRequest(url: Link.singleUser.url)
        request.httpMethod = "POST"
        
        let userQuery = PostUserQuery(firstName: user.firstName, lastName: user.lastName)
        let jsonData = try? JSONEncoder().encode(userQuery)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data else {return}
            
            if let postUserQuery = try? JSONDecoder().decode(PostUserQuery.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(postUserQuery))
                }
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func deleteUser(with id: Int, completion: @escaping (Bool) -> Void) {
        let userURL = Link.singleUser.url.appending(component: "\(id)")
        var request = URLRequest(url: userURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion(response.statusCode == 20)
                }
            }
        }.resume()
    }
    
    // новый способ удаления с помощью async throws
    func deleteUserWithId(_ id: Int) async throws -> Bool {
        let userURL = Link.singleUser.url.appending(component: "\(id)")
        var request = URLRequest(url: userURL)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse {
            return (response.statusCode == 204)
        }
        return false
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
