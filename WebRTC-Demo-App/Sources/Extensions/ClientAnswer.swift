//
//  ClientAnswer.swift
//  WebRTC-Demo
//
//  Created by Владислав Панев on 07.04.2021.
//  Copyright © 2021 Stas Seldin. All rights reserved.
//

import Foundation

struct ClientAnswer: Codable {
    var sender_id: String
    var sdp: String
    
    func toJsonObj(completion: (Data) -> ()){
        var clientAnswerJson = [String:Any]()
        clientAnswerJson["sender_id"] = sender_id
        clientAnswerJson["sdp"] = sdp
        
        var json = [String:Any]()
        json["cmd"] = "client_answer"
        json["args"] = clientAnswerJson
        
        do{
            completion(try JSONSerialization.data(withJSONObject: json, options: []))
        }
        catch{
            print("Cant serialize ClientAnswer")
        }
    }
}

struct ClientIce: Codable {
    var sender_id: String
    var ice: Ice
    
    func toJsonObj(completion: (Data) -> ()){
        var iceJson = [String:Any]()
        iceJson["candidate"] = ice.candidate
        iceJson["sdpMid"] = ice.sdpMid
        iceJson["sdpMLineIndex"] = ice.sdpMLineIndex
        
        var clientIceJson = [String:Any]()
        clientIceJson["sender_id"] = sender_id
        clientIceJson["ice"] = iceJson
        
        var json = [String:Any]()
        json["cmd"] = "client_ice"
        json["args"] = clientIceJson
        
        do{
            completion(try JSONSerialization.data(withJSONObject: json, options: []))
        }
        catch{
            print("Cant serialize ClientIce")
        }
    }
}

struct Ice: Codable {
    var candidate: String
    var sdpMid: String
    var sdpMLineIndex: Int32
}

