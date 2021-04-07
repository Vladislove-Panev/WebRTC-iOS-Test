//
//  ChatResponseHelper.swift
//  WebRTC-Demo
//
//  Created by Владислав Панев on 07.04.2021.
//  Copyright © 2021 Stas Seldin. All rights reserved.
//

import Foundation

class ChatResponseHelper{
    static func decodeChatResponse<T: Decodable>(messageArgs: Data, completion: (T) -> ()){
        let chatMessage: T
        do{
            chatMessage = try JSONDecoder().decode(T.self, from: messageArgs)
            completion(chatMessage)
        }catch{
            print("Some error in decode chatResponse")
        }
    }
}
