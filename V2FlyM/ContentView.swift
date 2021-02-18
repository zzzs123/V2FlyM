//
//  ContentView.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        if #available(OSX 11.0, *) {
            Menu("Menu1") {
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
