//
//  V2rayMgr.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/19.
//

import Cocoa

class V2rayMgr {
    static let shared = V2rayMgr()
    
    private var process: Process?

    func install() -> Bool {
        guard let supportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else {
            print("error won't handle")
            return false
        }
        let installDir = supportDir + "/V2FlyM"
        let proxyConfPath = installDir + "/proxy_conf"
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
            let process = Process()
            process.arguments = ["-config"]
            process.executableURL = URL(fileURLWithPath: (self?.v2rayPath())!)
            process.launch()
            process.waitUntilExit()
            
            self?.process = process
        }
    }
    
    func unload() {
        if let process = process, process.isRunning {
            process.terminate()
        }
    }

    private func v2rayPath() -> String {
        let supportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        let installDir = supportDir + "/V2FlyM"
        let v2rayPath = installDir + "/v2ray-core/v2ray"
        let fileExists = FileManager.default.fileExists(atPath: v2rayPath)
        if fileExists {
            //TODO: check NSFilePosixPermissions
            return v2rayPath
        }
        return Bundle.main.path(forResource: "v2ray", ofType: nil, inDirectory: "v2ray-core")!
    }

}
