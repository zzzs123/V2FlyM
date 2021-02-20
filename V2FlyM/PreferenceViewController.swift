//
//  PreferenceViewController.swift
//  V2FlyM
//
//  Created by silly b on 2021/2/17.
//

import Cocoa

class PreferenceViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var rightView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension PreferenceViewController: NSTableViewDelegate, NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return 5
  }

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return [
        "image": NSImage(),
        "title": "TTTTTTT"
    ] as [String: Any?]
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    let xx = ImportScene()
    rightView.addSubview(xx.view)
  }

}
