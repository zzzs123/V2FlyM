//
//  ImportScene.swift
//  V2FlyM
//
//  Created by some on 2021/2/20.
//

import Cocoa
import ObjectMapper

class ImportScene: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
}

class ImportSceneView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        print("drag enter")
        
        return .copy
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        if let url = NSURL(from: sender.draggingPasteboard) as URL?, let string = try? String(contentsOf: url, encoding: .utf8) {
            let json = Mapper<Server>().map(JSONString: string)
            let file = ""
        }
    }
}
