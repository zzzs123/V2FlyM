//
//  main.swift
//  proxy_conf
//
//  Created by silly b on 2021/2/18.
//

import Foundation
import SystemConfiguration

//let processInfo = ProcessInfo.processInfo
//print("ProcessInfo.arguments: \(processInfo.arguments)")
//print("CommandLine.arguments: \(CommandLine.arguments)")
//    ➜  Debug ./proxy_conf
//    ProcessInfo.arguments: ["/Users/sillyb/Library/Developer/Xcode/DerivedData/V2FlyM-advtynsgkqfgvaftmfktvgoyrbct/Build/Products/Debug/proxy_conf"]
//    CommandLine.arguments: ["./proxy_conf"]

let arguments = CommandLine.arguments

if arguments.contains(where: { $0 == "--help" || $0 == "-h" }) {
    print(
      """

      Usage: proxy_conf [mode] [pac-url] [http-port] [sock-port]

      mode:
        config:
              as Pac
        proxy:
              as Global
        direct:
              maybe as off or manual
        save:
              save
        restore:
              restore

      --help | -h:
              Print this message.

      """)
    exit(EXIT_SUCCESS)
}

if CommandLine.argc < 5 {
    print("arguments count less than 4")
    exit(EXIT_SUCCESS)
}
print("arguments: \(arguments)")
print("arguments: \(arguments)")

//config requires pacURL,
let mode = arguments[1]
print("mode: \(mode)")

let pacURL = arguments[2]
print("pacURL: \(pacURL)")

let httpPort = arguments[3]
print("httpPort: \(httpPort)")

let socksPort = arguments[4]
print("socksPort: \(socksPort)")

var authRef: AuthorizationRef?
let authFlags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
let authStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)
if authStatus != noErr {
    print("error create authorization")
    exit(EXIT_SUCCESS)
}
if authRef == nil {
    print("no authorization has been granted to modify network configuration")
    exit(EXIT_SUCCESS)
}

let prefs = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, "V2FlyM" as CFString, nil, authRef)!
let plists = SCPreferencesGetValue(prefs, kSCPrefNetworkServices) as! Dictionary<CFString, AnyObject>

var proxies = [
    kCFNetworkProxiesHTTPEnable: 0,
    kCFNetworkProxiesHTTPSEnable: 0,
    kCFNetworkProxiesProxyAutoConfigEnable: 0,
    kCFNetworkProxiesSOCKSEnable: 0,
    kCFNetworkProxiesExceptionsList: [],
] as [CFString : Any]

for (key, val) in plists {
    if let hardware = val.value(forKeyPath: "Interface.Hardware") as? String, ["AirPort", "Wi-Fi", "Ethernet"].contains(hardware) {
        let prefsPath = "/\(kSCPrefNetworkServices)/\(key)/\(kSCEntNetProxies)" as CFString
        print("prefsPath: \(prefsPath)")
        if mode == "config" {
            proxies[kCFNetworkProxiesProxyAutoConfigURLString] = Int(pacURL)! as NSNumber
            proxies[kCFNetworkProxiesProxyAutoConfigEnable] = NSNumber(1)
            SCPreferencesPathSetValue(prefs, prefsPath, proxies as CFDictionary)
        } else if mode == "proxy" {
            proxies[kCFNetworkProxiesSOCKSProxy] = "127.0.0.1"// as AnyObject //socks5ListenAddress
            proxies[kCFNetworkProxiesSOCKSPort] = Int(socksPort)!
            proxies[kCFNetworkProxiesSOCKSEnable] = 1

            proxies[kCFNetworkProxiesHTTPProxy] = "127.0.0.1" as AnyObject
            proxies[kCFNetworkProxiesHTTPPort] = Int(httpPort)! as NSNumber
            proxies[kCFNetworkProxiesHTTPEnable] = NSNumber(1)

            proxies[kCFNetworkProxiesHTTPSProxy] = "127.0.0.1" as AnyObject
            proxies[kCFNetworkProxiesHTTPSPort] = Int(httpPort)! as NSNumber
            proxies[kCFNetworkProxiesHTTPSEnable] = NSNumber(1)

            SCPreferencesPathSetValue(prefs, prefsPath, proxies as CFDictionary)
        } else if mode == "direct" {
            SCPreferencesPathSetValue(prefs, prefsPath, proxies as CFDictionary)

            print("没写呢")
            exit(EXIT_SUCCESS)
        }
        
        SCPreferencesCommitChanges(prefs);
        SCPreferencesApplyChanges(prefs);
        SCPreferencesSynchronize(prefs);

        print("proxies: \(proxies)")
        print("set mode: \(String(describing: mode))")

//        exit(EXIT_SUCCESS) //keng
    }

}

