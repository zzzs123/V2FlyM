//
//  AppDelegate.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/11.
//

import Cocoa
import RxSwift
import RxCocoa
import SystemConfiguration

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let disposeBag = DisposeBag()
    let coreLoaded = BehaviorSubject(value: false)
    
    var coreProcess: Process?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.button?.title = "M"
        
        let menu = NSMenu(title: "Menu")
        let flagItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        flagItem.state = .off
        let loadItem = NSMenuItem(title: "", action: #selector(load), keyEquivalent: "")
        
        let separator = NSMenuItem.separator()

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        
        let installItem = NSMenuItem(title: "Install", action: #selector(install), keyEquivalent: "")
        
        let proxyItem = NSMenuItem(title: "Set Proxy", action: #selector(setProxy), keyEquivalent: "")
        proxyItem.state = .on

        menu.items.append(flagItem)
        menu.items.append(loadItem)
        menu.items.append(separator)
        menu.items.append(proxyItem)
        menu.items.append(quitItem)
        menu.items.append(installItem)

        statusItem.menu = menu

        coreLoaded.asObservable().observe(on: MainScheduler.asyncInstance).subscribe(onNext: { v in
            flagItem.title = v ? "loaded" : "unloaded"
            loadItem.title = v ? "Unload" : "Load"
        }).disposed(by: disposeBag)

//        let contentView = ContentView()
//
//        // Create the window and set the content view.
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.isReleasedWhenClosed = false
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        unload()
    }
    
    @objc func load() {
        guard let isLoaded = try? coreLoaded.value() else { return }
        coreLoaded.onNext(!isLoaded)
        if isLoaded {
            unload()
        } else {
            if let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first, let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
                
                let workingDirectory = applicationSupportDirectory + "/V2FlyM"
                //            let programArguments = ["./v2ray-core/v2ray", "-config", "config.json"]
                //
                //            let plist: NSDictionary = [
                //                "Label": launch_agent_label,
                //                "WorkingDirectory": workingDirectory,
                ////                "StandardOutPath": logFilePath,
                ////                "StandardErrorPath": logFilePath,
                //                "ProgramArguments": programArguments,
                //                "KeepAlive": false,
                //            ]
                
                let v2rayPath = workingDirectory + "/v2ray-core/v2ray"
                let configPath = workingDirectory + "/config.json"
                //            plist.write(toFile: path, atomically: true)
                
                let fileExists = FileManager.default.fileExists(atPath: v2rayPath)
                if fileExists {
                    print("v2ray exists")
                    unload()
                    DispatchQueue.global().async { [weak self] in
                        self?.coreProcess = Process()
                        self?.coreProcess?.arguments = ["-config", configPath]
                        self?.coreProcess?.launchPath = v2rayPath
                        self?.coreProcess?.launch()
    //                        .launchedProcess(launchPath: v2rayPath, arguments: ["-config", configPath])
                        self?.coreProcess?.waitUntilExit()
                    }
//                    print(coreProcess?.terminationStatus)
                }
            }
        }
    }
        
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    @objc func install() {
        if let sh = Bundle.main.path(forResource: "launch", ofType: "sh"), let scriptObject = NSAppleScript(source: "do shell script \"sh \(sh)\" with administrator privileges") {
            var errorInfo: NSDictionary?
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&errorInfo)
            print(output.stringValue ?? "")
            if (errorInfo != nil) {
                print("do shell script error: \(String(describing: errorInfo))")
            }
        }
    }
    
    func unload() {
        if let c = coreProcess, c.isRunning {
            c.terminate()
        }
    }
    
    @objc func setProxy() {
        var authRef: AuthorizationRef?

        let authStatus = AuthorizationCreate(nil, nil, [.interactionAllowed, .extendRights, .preAuthorize], &authRef)
        guard authStatus == noErr else {
            print("authStatus error")
            return
        }
        guard authRef != nil else {
            print("No authorization has been granted to modify network configuration")
            return
        }
        
        let pref = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, "V2FlyM" as CFString, nil, authRef)!
        let sets = SCPreferencesGetValue(pref, kSCPrefNetworkServices)!
        
        var proxies = [NSObject: AnyObject]()
        // socks
        proxies[kCFNetworkProxiesSOCKSEnable] = 1 as NSNumber
        proxies[kCFNetworkProxiesSOCKSProxy] = "127.0.0.1" as AnyObject?
        proxies[kCFNetworkProxiesSOCKSPort] = NSNumber(1081)
        proxies[kCFNetworkProxiesExcludeSimpleHostnames] = 1 as NSNumber

        // http
        proxies[kCFNetworkProxiesHTTPEnable] = 1 as NSNumber
        proxies[kCFNetworkProxiesHTTPProxy] = "127.0.0.1" as AnyObject?
        proxies[kCFNetworkProxiesHTTPPort] = NSNumber(8001)
        proxies[kCFNetworkProxiesExcludeSimpleHostnames] = 1 as NSNumber

        // https
        proxies[kCFNetworkProxiesHTTPSEnable] = 1 as NSNumber
        proxies[kCFNetworkProxiesHTTPSProxy] = "127.0.0.1" as AnyObject?
        proxies[kCFNetworkProxiesHTTPSPort] = NSNumber(8001)
        proxies[kCFNetworkProxiesExcludeSimpleHostnames] = 1 as NSNumber

        sets.allKeys!.forEach { (key) in
            let dict = sets.object(forKey: key)!
            let hardware = (dict as AnyObject).value(forKeyPath: "Interface.Hardware")

            if hardware != nil && ["AirPort", "Wi-Fi", "Ethernet"].contains(hardware as! String) {
                SCPreferencesPathSetValue(pref, "/\(kSCPrefNetworkServices)/\(key)/\(kSCEntNetProxies)" as CFString, proxies as CFDictionary)
            }
        }

        SCPreferencesCommitChanges(pref)
        SCPreferencesApplyChanges(pref)
        SCPreferencesSynchronize(pref)
    }
}

