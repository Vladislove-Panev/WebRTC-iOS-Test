//
//  CrmDataProvider.swift
//  WebRTC-Demo
//
//  Created by Владислав Панев on 07.04.2021.
//  Copyright © 2021 Stas Seldin. All rights reserved.
//

import Foundation

protocol CrmDataProvider : AnyObject {
    var delegate: CrmDataProviderDelegate? { get set }
}

protocol CrmDataProviderDelegate : AnyObject {
    func dataDidRecieve(_ requester: CrmDataProvider, didRecieveData data: String)
}
