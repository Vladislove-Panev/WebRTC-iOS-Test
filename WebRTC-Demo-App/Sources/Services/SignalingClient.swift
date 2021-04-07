//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    private var timer: Timer!
    weak var delegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect(userId: AppData.CrmId, token: AppData.Token)
        startKeepAlive()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription) {
        let clientAnswer = ClientAnswer(sender_id: AppData.CrmId, sdp: rtcSdp.sdp)
        
        print(rtcSdp.sdp)
        
        clientAnswer.toJsonObj(){ (data) in
            self.webSocket.send(data: data)
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let clientIce = ClientIce(sender_id: AppData.CrmId, ice: Ice(candidate: rtcIceCandidate.sdp,sdpMid: rtcIceCandidate.sdpMid!, sdpMLineIndex: rtcIceCandidate.sdpMLineIndex))
            
        clientIce.toJsonObj(){ (data) in
            self.webSocket.send(data: data)
        }
    }
    
    private func startKeepAlive(){
        timer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { timer in
            self.webSocket.send(string: ".")
        }
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocket(_ webSocket: WebSocketProvider, didReceiveString str: String) {
        do{
            let data = str.data(using: .utf8)!
            let chatResponseMessage = try JSONDecoder().decode(ChatResponseMessage.self, from: data)
            
            switch chatResponseMessage.cmd {
                case "manager_offer":
                    ChatResponseHelper.decodeChatResponse(messageArgs: data){ (managerOffer: ChatOfferResponseMessage) in
                        self.delegate?.signalClient(self, didReceiveRemoteSdp: managerOffer.args.rtcSessionDescription)
                    }
                case "manager_ice":
                    ChatResponseHelper.decodeChatResponse(messageArgs: data){ (managerIce: ChatIceResponseMessage) in
                        self.delegate?.signalClient(self, didReceiveCandidate: managerIce.args.ice.rtcIceCandidate)
                        }
                default:
                    print("Unhandled chat message")
            }
        }catch{
            print("Some error with JSON encode/decode")
        }
    }
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect(userId: AppData.CrmId, token: AppData.Token)
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        }
        catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }

    }
}
