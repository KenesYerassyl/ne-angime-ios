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
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
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
}

struct APIClient {
    typealias APIClientCompletion = (Data?, HTTPURLResponse?, APIError?) -> Void
    private let session = URLSession.shared
    private let baseURL = "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/"
    
    func request(_ request: APIRequest, completion: @escaping(APIClientCompletion)) {
        guard let url = URL(string: "\(baseURL)\(request.path)") else {
            completion(nil, nil, .invalidURL)
            return
        }
        var urlRequest = URLRequest(url: url)
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
}
