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
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let url = URL(string: "ws://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app:80/?token=\(token)") else { return }
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession?.webSocketTask(with: url)
    }
    
    public func resetTask() {
        urlSession = nil
        webSocketTask = nil
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let url = URL(string: "ws://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app:80/?token=\(token)") else { return }
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
                print(print("Error when receiving \(error)"))
            }
            self.receive()
        })
    }
    
    private func distributeData(data: Data) {
        do {
            let messageWebSocket = try JSONDecoder().decode(MessageWebSocket.self, from: data)
            switch messageWebSocket.type {
            case .receiveMessage:
                MessageHandler.shared.handleMessage(messageWebSocket: messageWebSocket)
            case .sendMessage:
                print("This will not happen")
            }
        } catch {
            print("Error in distributing data: \(error)")
        }
    }
    
    public func connect() {
        print("trying to connect...")
        webSocketTask?.resume()
    }
    
    public func disconnect() {
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
