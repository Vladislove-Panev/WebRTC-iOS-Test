//
//  ChatResponseMessage.swift
//  WebRTC-Demo
//
//  Created by Владислав Панев on 07.04.2021.
//  Copyright © 2021 Stas Seldin. All rights reserved.
//

import Foundation
import WebRTC

struct ChatResponseMessage: IChatResponseMessage {
    var cmd: String
}

struct ChatOfferResponseMessage: IChatResponseMessage {
    var cmd: String
    let args: ManagerOffer
}

struct ChatIceResponseMessage: IChatResponseMessage {
    var cmd: String
    let args: ManagerIce
}

struct ChatStopResponseMessage: IChatResponseMessage {
    var cmd: String
    let args: ManagerStop
}

struct ManagerIce: Decodable {
    let client_id: String
    let ice: IceCandidate
}

struct ManagerOffer: Decodable {
    let client_id: String
    let sdp: String
    let ice_server: UserCredential
    
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: .offer, sdp: self.sdp)
    }
}

struct ManagerStop : Decodable {
    let client_id: String
}

struct UserCredential: Decodable {
    let credential: String
    let urls: String
    let username: String
}

protocol IChatResponseMessage: Decodable {
    var cmd: String { get set }
}
