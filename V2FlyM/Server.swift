//
//  Server.swift
//  V2FlyM
//
//  Created by silly b on 2021/3/6.
//

import Cocoa

protocol ServerProtocol: Codable {
    var address: String { get }
    var remarks: String { get }
    
}

protocol VmessServerProtocol: ServerProtocol {
    
}

class VmessServer: VmessServerProtocol {
    var remarks: String = "vmess"
    
    var address: String = ""
    
    func encode(to encoder: Encoder) throws {
        
    }
}
