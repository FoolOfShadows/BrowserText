//
//  CurrentMedsController.swift
//  SampleCheckOutTab
//
//  Created by Fool on 8/16/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class PMCurrentMedsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	
	@IBOutlet weak var currentMedsTableView: NSTableView!
	
	var medicationsString = String()
	var medListArray = [String]()
	var chosenMeds = [String]()
    
    var checkBoxState = [NSButton.StateValue]()
	
	weak var medReloadDelegate: scriptTableDelegate?
	

    override func viewDidLoad() {
        super.viewDidLoad()
		//medicationsString = cleanArray()
		medListArray = getArrayFrom(medicationsString)
		self.currentMedsTableView.reloadData()
    }
	
	func numberOfRows(in tableView: NSTableView) -> Int {
        checkBoxState = Array(repeating: NSButton.StateValue.off, count: medListArray.count)
		return medListArray.count
	}
	
	func getArrayFrom(_ medsString:String) -> [String] {
		let returnArray = medsString.removeWhiteSpace().components(separatedBy: "\n").filter { $0 != "" && $0 != "  " && !$0.lowercased().starts(with: "stop") && !$0.lowercased().starts(with: "start")}
		return returnArray
	}
	

	
	//Set up the tableview with the data from the medList array
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//		guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
//
//		vw.textField?.stringValue = medListArray[row]
//
//		return vw
        //The simple set up above broke with macOS Monterey and required a more detailed creation of the table
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "textViewColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "textViewCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = medListArray[row]
            return cellView
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkBoxColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "checkBoxCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            let theCheckBox = cellView.subviews[0] as! NSButton
            theCheckBox.state = checkBoxState[row]
            return cellView
        }
        return nil
	}
    
	
	
	@IBAction func getDataFromSelectedRow(_ sender:Any) {
		let currentRow = currentMedsTableView.row(for: sender as! NSView)

		if (sender as! NSButton).state == .on {
			chosenMeds.append(medListArray[currentRow])
            checkBoxState[currentRow] = .on
		} else if (sender as! NSButton).state == .off {
            checkBoxState[currentRow] = .off
			chosenMeds = chosenMeds.filter { $0 != medListArray[currentRow] }
		}
	}
	
	@IBAction func getDataFromSelectedRowsText(_ sender:Any) {
        let currentRow = currentMedsTableView.row(for: sender as! NSView)
        let currentCellView = currentMedsTableView.rowView(atRow: currentRow, makeIfNecessary: false)?.view(atColumn: 1) as! NSTableCellView
        guard let currentText = currentCellView.textField?.stringValue else { return }
        
        
        if (sender as! NSButton).state == .on {
            chosenMeds.append(currentText)
        } else if (sender as! NSButton).state == .off {
            chosenMeds = chosenMeds.filter { $0 != currentText}
        }
		
		
	}
	

	
	@IBAction func returnResults(_ sender:Any) {
		let firstVC = presentingViewController as! PhoneMessageVC
		firstVC.wantedMeds += chosenMeds
		medReloadDelegate?.currentMedsWillBeDismissed(sender: self)
		self.dismiss(self)
	}
}
