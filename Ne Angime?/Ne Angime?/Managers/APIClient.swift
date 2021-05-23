//
//  APIClient.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/10/21.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

struct HTTPHeader {
    let field: String
    let value: String
}

struct APIRequest {
    let method: HTTPMethod
    let path: String
    var headers: [HTTPHeader]?
    var body: Data?

    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
    }
}

enum APIError: String, Error {
    case invalidURL
    case noResponse
    case noAccessToken
}

struct APIClient {
    typealias APIClientCompletion = (Data?, HTTPURLResponse?, APIError?) -> Void
    private let session = URLSession.shared
    private let baseURL = "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/"
    
    func request(_ request: APIRequest, isAccessTokenRequired: Bool, completion: @escaping(APIClientCompletion)) {
        guard let url = URL(string: "\(baseURL)\(request.path)") else {
            completion(nil, nil, .invalidURL)
            return
        }
        var urlRequest = URLRequest(url: url)
        if isAccessTokenRequired {
            guard let accessToken = UserDefaults.standard.string(forKey: "access_token") else {
                completion(nil, nil, .noAccessToken)
                return
            }
            urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.body
        urlRequest.httpMethod = request.method.rawValue
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(data, httpResponse, error as? APIError)
            } else {
                completion(nil, nil, .noResponse)
            }
        }.resume()
    }
    
    func request(_ url: URL, completion: @escaping(APIClientCompletion)) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(data, httpResponse, error as? APIError)
            } else {
                completion(nil, nil, .noResponse)
            }
        }.resume()
    }
    
    func refresh(_ completion: @escaping(Result) -> Void) {
        if let refreshToken = UserDefaults.standard.string(forKey: "refresh_token"),
           let data = try? JSONSerialization.data(withJSONObject: ["refresh_token" : refreshToken]) {
            var refreshRequest = APIRequest(method: .post, path: "user/auth/refresh_token")
            refreshRequest.body = data
            request(refreshRequest, isAccessTokenRequired: false) { (data, response, error) in
                if let data = data, let response = response {
                    if (200...299).contains(response.statusCode),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                       let userData = json["data"] as? [String : Any],
                       let newAccessToken = userData["access_token"],
                       let newRefreshToken = userData["refresh_token"] {
                        UserDefaults.standard.set(newAccessToken, forKey: "access_token")
                        UserDefaults.standard.set(newRefreshToken, forKey: "refresh_token")
                        completion(.success)
                    } else if response.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOut, object: nil)
                    } else {
                        print("Unexpected error occured in requesting refresh_token: unhandled response status code \(response.statusCode).")
                        completion(.failure)
                    }
                } else if let error = error {
                    print("Error in refreshing access token: \(error)")
                    completion(.failure)
                } else {
                    print("Unexpected error occured: data, response, and error are all nil.")
                    completion(.failure)
                }
            }
        } else {
            fatalError("Failed to refresh access token: No refresh token OR failure in serializing JSON data")
        }
    }
}
