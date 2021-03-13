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
    
    func getAllConversations(_ completion: @escaping([Conversation]?) -> Void) {
        guard let cookie = UserDefaults.standard.string(forKey: "token") else {
            completion(nil)
            return
        }
        var request = APIRequest(method: .get, path: "chat")
        request.headers = [HTTPHeader(field: "Cookie", value: "token=\(cookie)")]
        
        APIClient().request(request) { (data, response, error) in
            if let data = data, let response = response, (200...299).contains(response.statusCode) {
                do {
                    let decoder = JSONDecoder()
                    let conversations = try decoder.decode([Conversation].self, from: data)
                    DispatchQueue.main.async { completion(conversations) }
                } catch {
                    print("Error in decoding [Conversation] data: \(error)")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else if let error = error {
                print("Erro in all conversations: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    func doesConversationExist(_ targetConversation: Conversation, in conversations: [Conversation]) -> Bool {
        for conversation in conversations {
            if conversation.conversationID == targetConversation.conversationID { return true }
        }
        return false
    }
}
