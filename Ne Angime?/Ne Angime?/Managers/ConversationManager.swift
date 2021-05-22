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
        let request = APIRequest(method: .get, path: "chat")
        
        APIClient().request(request, isAccessTokenRequired: true) { (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let conversations = try decoder.decode([Conversation].self, from: data)
                        completion(conversations)
                    } catch {
                        print("Error in decoding [Conversation] data: \(error)")
                        completion(nil)
                    }
                } else if response.statusCode == 401 {
                    APIClient().refresh { (result) in
                        if result == .success {
                            self.getAllConversations { conversations in completion(conversations) }
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    print("Unexpected error occured: unhandled response status code.")
                    completion(nil)
                }
            } else if let error = error {
                print("Error in all conversations: \(error)")
                completion(nil)
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
