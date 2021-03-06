//
//  WebSocketManager.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation

protocol WebSocket {
    <#requirements#>
}

class WebSocket: NSObject{
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    
    override init() {
        super.init()
        guard let url = URL(string: "ws://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app:80/?token=tokenFromLogin"),
              let token = UserDefaults.standard.string(forKey: "token") else { return }
        var request = URLRequest(url: url)
        request.addValue("token=\(token)", forHTTPHeaderField: "Cookie")
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: request)
    }
    
    public func connect() {
        webSocketTask?.resume()
        
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
                    print("Data received")
                case .string(let text):
                    print("Text received: \(text)")
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                print(print("Error when receiving \(error)"))
            }
            self.receive()
        })
    }
    
    public func close() {
        let reason = "Closing connection".data(using: .utf8)
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
