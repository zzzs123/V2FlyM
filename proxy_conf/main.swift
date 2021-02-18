//
//  main.swift
//  proxy_conf
//
//  Created by silly b on 2021/2/18.
//

import Foundation
import SystemConfiguration

let processInfo = ProcessInfo.processInfo
print("ProcessInfo.arguments: \(processInfo.arguments)")

print("CommandLine.arguments: \(CommandLine.arguments)")
//    ➜  Debug ./proxy_conf
//    ProcessInfo.arguments: ["/Users/sillyb/Library/Developer/Xcode/DerivedData/V2FlyM-advtynsgkqfgvaftmfktvgoyrbct/Build/Products/Debug/proxy_conf"]
//    CommandLine.arguments: ["./proxy_conf"]

let arguments = CommandLine.arguments.dropFirst()
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

if arguments.count < 4 {
    exit(EXIT_SUCCESS)
}

//config requires pacURL,
let mode = arguments.first
let pacURL = arguments[1]
let httpPort = arguments[2]
let sockPort = arguments.last

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

