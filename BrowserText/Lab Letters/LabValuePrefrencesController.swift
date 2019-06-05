//
//  LabValuePrefrencesController.swift
//  LabLetters
//
//  Created by Fool on 5/9/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class LabValuePrefrencesController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	@IBOutlet var labPrefView: NSView!
	@IBOutlet weak var labPrefTableView: NSTableView!
	
	var labList = ["WBC", "HGB", "HCT", "PLT"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return labList.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
		vw.textField?.stringValue = labList[row]
		
		return vw
	}
    
	@IBAction func takeOK(_ sender: NSButton) {
		dismiss(self)
	}
}
