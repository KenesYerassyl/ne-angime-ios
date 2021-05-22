//
//  WebSocketManager.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation

class WebSocket: NSObject{
    public static let shared = WebSocket()
    private var urlSession: URLSession?
    var webSocketTask: URLSessionWebSocketTask?
    
    override init() {
        super.init()
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "ws://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app:80/?token=\(accessToken)") else { return }
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession?.webSocketTask(with: url)
    }
    
    func resetTask() {
        urlSession = nil
        webSocketTask = nil
        
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "ws://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app:80/?token=\(accessToken)") else { return }
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession?.webSocketTask(with: url)
    }
    
    private func ping() {
        webSocketTask?.sendPing(pongReceiveHandler: { (error) in
            if let error = error {
                print("Error when sending PING \(error)")
            } else {
                print("Web Socket connection is alive")
                DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                    self.ping()
                }
            }
        })
    }
    
    private func receive() {
        webSocketTask?.receive(completionHandler: { (result) in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data received: \(data)")
                case .string(let text):
                    print("Text received: \(text)")
                    let dataFromText = text.data(using: .utf8)
                    guard let dataToSend = dataFromText else { return }
                    self.distributeData(data: dataToSend)
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                let EE = error
//                print("Error when receiving \(error)")
            }
            self.receive()
        })
    }
    
    func sendMessageStatus(message: Message, conversationID: String, completion: @escaping(Result) -> Void) {
        let messageStatusWebSocket = MessageWebSocket(
            type: .setMessageStatusSeen,
            messageID: message.messageID,
            conversationID: conversationID,
            senderUsername: message.senderUsername,
            recipientUsername: message.recipientUsername
        )
        do {
            let data = try JSONEncoder().encode(messageStatusWebSocket)
            WebSocket.shared.webSocketTask?.send(.data(data), completionHandler: { error in
                if let error = error {
                    print("Error in sending data: \(error)")
                    completion(.failure)
                } else {
                    completion(.success)
                }
            })
        } catch {
            completion(.failure)
            print("Error in encoding message status change: \(error)")
        }
    }
    
    private func distributeData(data: Data) {
        do {
            let messageWebSocket = try JSONDecoder().decode(MessageWebSocket.self, from: data)
            switch messageWebSocket.type {
            case .receiveMessage:
                MessageHandler.shared.handleMessage(messageWebSocket: messageWebSocket)
            case .sendMessage:
                print("Error: an app cannot receive such type of message. It only sends it")
            case .getMessageStatusSeen:
                MessageHandler.shared.handleStatusChangeMessage(messageWebSocket: messageWebSocket)
            case .setMessageStatusSeen:
                print("Error: an app cannot receive such type of message. It only sends it")
            }
        } catch {
            print("Error in distributing data: \(error)")
        }
    }
    
    func connect() {
        print("trying to connect...")
        webSocketTask?.resume()
    }
    
    func disconnect() {
        let reason = "disconnecting".data(using: .utf8)
        webSocketTask?.cancel(with: .goingAway, reason: reason)
    }
}

extension WebSocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did connect!")
        ping()
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Websocket did disconnect!")
    }
}
