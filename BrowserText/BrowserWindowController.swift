//
//  BrowserWindowController.swift
//  BrowserText
//
//  Created by Fool on 5/17/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

class BrowserWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let theWindow = window else { return }
        
        //restore position
        theWindow.setFrameUsingName("BrowserWindow")
        self.windowFrameAutosaveName = "BrowserWindow"
    }

}
