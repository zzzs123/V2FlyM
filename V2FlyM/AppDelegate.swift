//
//  AppDelegate.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/11.
//

import Cocoa
import RxSwift
import RxCocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let v2rayMgr = V2rayMgr.shared
    
    let disposeBag = DisposeBag()
    let toggleV2ray = BehaviorSubject(value: false)

    let menu = NSMenu(title: "Menu")
    
    let flagItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    let toggleItem = NSMenuItem(title: "", action: #selector(toggle), keyEquivalent: "")
    
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        

    let modeItem = NSMenuItem(title: "Routing", action: nil, keyEquivalent: "")
    let configItem = NSMenuItem(title: "Config", action: #selector(routing), keyEquivalent: "")
    let proxyItem = NSMenuItem(title: "Proxy", action: #selector(routing), keyEquivalent: "")
    let directItem = NSMenuItem(title: "Direct", action: #selector(routing), keyEquivalent: "")

    let currentMode = BehaviorSubject<Mode>(value: Mode.config)
    
    enum Mode: String {
        case config = "Config"
        case proxy = "Proxy"
        case direct = "Direct"
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if v2rayMgr.install() == false {
            NSApp.terminate(nil)
        }
        self.statusItem.button?.imageHugsTitle = false
        self.statusItem.button?.imagePosition = .imageLeading

        flagItem.isEnabled = false
        modeItem.isEnabled = false

        menu.items.append(flagItem)
        menu.items.append(toggleItem)
        menu.items.append(NSMenuItem.separator())
        menu.items.append(modeItem)
        menu.items.append(configItem)
        menu.items.append(proxyItem)
        menu.items.append(directItem)
        menu.items.append(NSMenuItem.separator())
        menu.items.append(quitItem)

        statusItem.menu = menu

        toggleV2ray.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] isLoad in
            guard let self = self else { return }
            self.v2rayMgr.unload()
            if isLoad {
                self.v2rayMgr.load()
            }

            self.flagItem.title = isLoad ? "Connected" : "Not Connected"
            self.flagItem.state = isLoad ? .on : .off
            self.toggleItem.title = isLoad ? "Disconnect" : "Connect"
            
            self.statusItem.button?.image = isLoad ? NSImage(named: "status_bar_on") : NSImage(named: "status_bar_off")
        }).disposed(by: disposeBag)

        currentMode.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] mode in
            self?.configItem.state = mode == .config ? .on : .off
            self?.proxyItem.state = mode == .proxy ? .on : .off
            self?.directItem.state = mode == .direct ? .on : .off
            
            self?.statusItem.button?.title = mode.rawValue
        }).disposed(by: disposeBag)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        v2rayMgr.unload()
    }
    
    @objc func toggle() {
        guard let load = try? toggleV2ray.value() else { return }
        toggleV2ray.onNext(!load)
    }
        
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    @objc func routing(item: NSMenuItem) {
        if item == configItem {
            currentMode.onNext(.config)
        } else if item == proxyItem {
            currentMode.onNext(.proxy)
        } else if item == directItem {
            currentMode.onNext(.direct)
        }
    }

}

