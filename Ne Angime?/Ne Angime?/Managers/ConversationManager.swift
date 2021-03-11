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
    
    func convertToConversation(from conversationCoreData: ConversationCoreData) -> Conversation {
        var conversation = Conversation(
            conversationID: conversationCoreData.conversationID ?? "undefined",
            messages: []
        )
        guard let messages = conversationCoreData.messages as? Set<MessageCoreData> else { return conversation }
        for messageCoreData in messages {
            let message = Message(
                createdAt: messageCoreData.createdAt,
                message: messageCoreData.message ?? "undefined",
                messageID: messageCoreData.messageID ?? "undefined",
                recipientUsername: messageCoreData.recipientUsername ?? "undefined",
                senderUsername: messageCoreData.senderUsername ?? "undefined"
            )
            conversation.messages.append(message)
        }
        return conversation
    }
}
