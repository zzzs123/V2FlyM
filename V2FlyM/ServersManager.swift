//
//  ServersManager.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/22.
//

import Cocoa
import RxSwift
import ObjectMapper

class ServersManager {
    static let shared = ServersManager()

    private var currentServer: ServerProtocol?
    
    let currentServerSubject = BehaviorSubject<Data?>(value: nil)

    private var servers = [ServerProtocol]()

    let list = BehaviorSubject<[ServerProtocol?]>(value: [])
    
//    func load() {
//        if let val = UserDefaults.standard.array(forKey: Constants.KEY_SERVERS) as? [[String: Any]], val.count > 0 {
//            let s = val.map {
//                Mapper<Server>().map(JSON: $0)
//            }
//            list.onNext(s)
//        }
//    }
}
