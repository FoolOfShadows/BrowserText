//
//  ReceiptVC.swift
//  BrowserText
//
//  Created by Fool on 7/15/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

class ReceiptVC: NSViewController {

    
    weak var viewDataDelegate: webViewDataProtocol?
    var patientData = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let theWindow = self.view.window {
            theWindow.title = "Receipt"
            //This removes the ability to resize the window of a view
            //opened by a segue
            theWindow.styleMask.remove(.resizable)
            //This makes the window float at the front of the other windows
            //Does the staff want this window to float? - no 5/23/19
            //theWindow.level = .floating
            theWindow.setFrameUsingName("receipt")
            theWindow.windowController!.windowFrameAutosaveName = "receipt"
        }
    }
    
    func startNewReceipt() {
        let currentReceipt = Receipt(theText: patientData)
    }
}
