//
//  V2rayManager.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/19.
//

import Cocoa
import ObjectMapper
import RxSwift

class V2rayManager {
    
    static let shared = V2rayManager()
    
    private let disposeBag = DisposeBag()

    private var process: Process?

    private let flymmPathComponent = "/V2FlyM"
    
    var installPath: String {
        guard let supportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else {
            return NSHomeDirectory() + "/Library/Application Support" + flymmPathComponent
        }
        return supportDir + flymmPathComponent
    }
    
    var v2rayPath: String {
        let path = installPath + "/v2ray-core/v2ray"
        let fileExists = FileManager.default.fileExists(atPath: path)
        if fileExists {
            //TODO: check NSFilePosixPermissions
            return path
        }
        return Bundle.main.path(forResource: "v2ray", ofType: nil, inDirectory: "v2ray-core")!
    }

    var proxyConfPath: String {
        let path = installPath + "/proxy_conf"
        return path
    }

    var jsonPath: String? {
        let path = installPath + "/config.json"
        let fileExists = FileManager.default.fileExists(atPath: path)
        if fileExists {
            return path
        }
        return nil
    }
    
    func install() -> Bool {
        let fileExists = FileManager.default.fileExists(atPath: proxyConfPath)
        //need verify version
        if fileExists {
            return true
        }
        
        guard let sh = Bundle.main.path(forResource: "install", ofType: "sh"), let scriptObject = NSAppleScript(source: "do shell script \"sh \(sh)\" with administrator privileges") else {
            print("error won't handle")
            return false
        }
        
        var errorInfo: NSDictionary?
        let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&errorInfo)
        print(output.stringValue ?? "")
        if (errorInfo != nil) {
            print("do shell script error: \(String(describing: errorInfo))")
            return false
        }
        return true
    }

    func load() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
//            let json = Bundle.main.path(forResource: "template", ofType: "json")
//            let data = try! Data(contentsOf: URL(fileURLWithPath: json!))
//
//            let xxx = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//            let mmm = Mapper<Server>().map(JSONObject: xxx)
            let process = Process()
//            process.arguments = ["-config"]
            process.executableURL = URL(fileURLWithPath: self.v2rayPath)
            process.launch()
            process.waitUntilExit()
            
            self.process = process
        }
    }
    
    func unload() {
        if let process = process, process.isRunning {
            process.terminate()
        }
    }
    
    init() {
        ServersManager.shared.currentServerSubject.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] data in
            guard let data = data else { return }
            self?.unload()
            self?.load(data: data)
        }).disposed(by: disposeBag)
    }

    func load(data: Data) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
//            let json = Bundle.main.path(forResource: "template", ofType: "json")
//            let data = try! Data(contentsOf: URL(fileURLWithPath: json!))
//
//            let xxx = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//            let mmm = Mapper<Server>().map(JSONObject: xxx)
            let task = Process()
            task.launchPath = self.proxyConfPath
            task.arguments = ["proxy", " ", "8001", "1081"]
            task.launch()
            task.waitUntilExit()

            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.v2rayPath)
            process.arguments = ["-config", "stdin:"]
            let pipe = Pipe()
            pipe.fileHandleForWriting.write(data)
            process.standardInput = pipe
            process.launch()
            process.waitUntilExit()
            
            self.process = process
            

        }
    }

}
