//
//  NHAdmitVC.swift
//  BrowserText
//
//  Created by Fool on 1/9/20.
//  Copyright © 2020 Fool. All rights reserved.
//

import Cocoa

class NHAdmitVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var nhNameCombo: NSComboBox!
    @IBOutlet weak var conditionCombo: NSComboBox!
    @IBOutlet weak var vitalsCombo: NSComboBox!
    @IBOutlet weak var activityCombo: NSComboBox!
    @IBOutlet weak var nursingCombo: NSComboBox!
    @IBOutlet weak var dietCombo: NSComboBox!
    @IBOutlet weak var labsCombo: NSComboBox!
    @IBOutlet weak var otherView: NSTextField!
    
    @IBOutlet weak var dxTableView: NSTableView!
    @IBOutlet weak var medTableView: NSTableView!
    
    var medicationsString = String()
    var dxString = String()
    var medListArray = [String]()
    var dxListArray = [String]()

    weak var medDxDelegate: MedAndDiagnosisProtocol?
    var currentPatientData = ChartData(chartData: "", aptTime: "", aptDate: 00)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        medListArray = getMedArrayFrom(currentPatientData.currentMeds)
        //dxListArray = and array returned from currentPatienData.diagnosis
        nhNameCombo.clearComboBox(menuItems: NursingHome.nursingHomes)
        conditionCombo.clearComboBox(menuItems: Condition.conditions)
        vitalsCombo.clearComboBox(menuItems: Vitals.vitals)
        labsCombo.clearComboBox(menuItems: Lab.labs)
    }
    
    func getMedArrayFrom(_ medsString:String) -> [String] {
        let returnArray = medsString.removeWhiteSpace().components(separatedBy: "\n").filter { $0 != "" && $0 != "  " && !$0.lowercased().starts(with: "stop") && !$0.lowercased().starts(with: "start")}
        return returnArray
    }
    
    //Not sure if this is going to work
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == dxTableView {
            return dxListArray.count
        } else if tableView == medTableView {
            return medListArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        if tableView == medTableView {
            vw.textField?.stringValue = medListArray[row]
        } else if tableView == dxTableView {
            vw.textField?.stringValue = dxListArray[row]
        }
        
        return vw
    }
    
}
