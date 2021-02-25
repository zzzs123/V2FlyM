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
    
    lazy var flagItem: NSMenuItem = {
        let val = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        val.isEnabled = false
        return val
    }()
    
    let toggleItem = NSMenuItem(title: "", action: #selector(toggle), keyEquivalent: "")
    
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        
    lazy var modeItem: NSMenuItem = {
        let val = NSMenuItem(title: "Routing", action: nil, keyEquivalent: "")
        val.isEnabled = false
        return val
    }()

    let configItem = NSMenuItem(title: "Config", action: #selector(routing), keyEquivalent: "")
    let proxyItem = NSMenuItem(title: "Proxy", action: #selector(routing), keyEquivalent: "")
    let directItem = NSMenuItem(title: "Direct", action: #selector(routing), keyEquivalent: "")
    
    var serverItems: [NSMenuItem]?

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

        menu.items = [flagItem,
                      toggleItem,
                      NSMenuItem.separator(),
                      modeItem,
                      configItem,
                      proxyItem,
                      directItem,
                      NSMenuItem.separator(),
                      quitItem]

        statusItem.menu = menu

        ServersManager.shared.list.skip(1)
            .map { [NSMenuItem(title: $0.debugDescription, action: nil, keyEquivalent: "")] }
            .subscribe(onNext: {
                var items = [self.flagItem,
                             self.toggleItem,
                             NSMenuItem.separator(),
                             self.modeItem,
                             self.configItem,
                             self.proxyItem,
                             self.directItem,
                             NSMenuItem.separator(),
                             NSMenuItem.separator(),
                             self.quitItem]
                items.insert(contentsOf: $0, at: 8)
                self.menu.items = items
            }).disposed(by: disposeBag)
                
        Observable.combineLatest(toggleV2ray, currentMode).observe(on: MainScheduler.asyncInstance).subscribe { [weak self] isLoad, mode in
            guard let self = self else { return }
            guard isLoad else {
                self.statusItem.button?.image = NSImage(named: "status_bar_off")
                return
            }
            var image: NSImage?
            if mode == .config {
                image = NSImage(named: "status_bar_on")
            } else if mode == .proxy {
                image = NSImage(named: "status_bar_on_red")
            } else if mode == .direct {
                image = NSImage(named: "status_bar_on_green")
            }
            self.statusItem.button?.image = image

        }.disposed(by: disposeBag)
        
        toggleV2ray.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] isLoad in
            guard let self = self else { return }
            self.v2rayMgr.unload()
            if isLoad {
                self.v2rayMgr.load()
            }

            self.flagItem.title = isLoad ? "Connected" : "Not Connected"
            self.flagItem.state = isLoad ? .on : .off
            self.toggleItem.title = isLoad ? "Disconnect" : "Connect"

        }).disposed(by: disposeBag)

        currentMode.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] mode in
            self?.configItem.state = mode == .config ? .on : .off
            self?.proxyItem.state = mode == .proxy ? .on : .off
            self?.directItem.state = mode == .direct ? .on : .off
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

