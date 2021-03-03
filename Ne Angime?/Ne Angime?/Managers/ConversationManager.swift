//
//  ConversationManager.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/3/21.
//

import Foundation

class ConversationManager {
    public static let shared = ConversationManager()
    private init(){}
    
    public func getAllConversations(_ completion: @escaping([Conversation]?, Error?) -> Void) {
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/chat"),
              let cookie = UserDefaults.standard.string(forKey: "token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("token=\(cookie)", forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299 {
                do {
                    let decoder = JSONDecoder()
                    decoder.userInfo[CodingUserInfoKey.context] = CoreDataManager.shared.context
                    let conversations = try decoder.decode([Conversation].self, from: data)
                    DispatchQueue.main.async { completion(conversations, nil) }
                } catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            } else if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        task.resume()
    }
}
