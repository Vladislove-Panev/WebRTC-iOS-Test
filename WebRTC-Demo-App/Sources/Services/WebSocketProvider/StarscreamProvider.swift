//
//  StarscreamProvider.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: WebSocket
    
    init(url: URL) {
        self.url = url
        self.socket = WebSocket(url: url)
    }
    
    func connect(userId: String, token: String) {
        var request = URLRequest(url: URL(string: "wss://chat.devshell.site/api/ws?userID=\(userId)")!)
        request.setValue(".ASPXAUTHAPI=\(token)", forHTTPHeaderField: "Cookie")
        request.timeoutInterval = 5
        
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
    
    func send(string: String) {
        self.socket.write(string: string)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.webSocketDidDisconnect(self)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.delegate?.webSocket(self, didReceiveData: data)
    }
    
    func websocketDidReceiveString(socket: WebSocketClient, string: String) {
        self.delegate?.webSocket(self, didReceiveString: string)
    }
}
