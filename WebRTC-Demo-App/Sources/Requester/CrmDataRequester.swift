//
//  CrmDataRequester.swift
//  WebRTC-Demo
//
//  Created by Владислав Панев on 07.04.2021.
//  Copyright © 2021 Stas Seldin. All rights reserved.
//

import Foundation

class CrmDataRequester {
    
    let sessionConfiguration = URLSessionConfiguration.ephemeral
    let customSession: URLSession
    
    init() {
        sessionConfiguration.httpCookieAcceptPolicy = .never
        customSession = URLSession(configuration: sessionConfiguration)
    }
    
    enum Result {
        case success(HTTPURLResponse, Data)
        case failure(Error)
    }
        
    func executeURLRequest(url: URL, inSession session: URLSession = .shared, completion: @escaping (Result) -> Void) {
        var json = [String:Any]()
        json["email"] = "11@mailna.co"
        json["password"] = "123qwe"
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request) { data, response, error in

                if let response = response as? HTTPURLResponse,
                    let data = data {
                    completion(.success(response, data))
                    return
                }

                if let error = error {
                    completion(.failure(error))
                    return
                }

                let error = NSError(domain: "com.cookiesetting.test", code: 101, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                completion(.failure(error))
            }
            task.resume()
            
        }catch{
            
        }
    }
}
