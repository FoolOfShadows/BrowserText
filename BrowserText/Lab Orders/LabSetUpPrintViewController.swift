//
//  LabPrintingViewController.swift
//  LIROS
//
//  Created by Fool on 11/1/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class LabSetUpPrintViewController: NSViewController {
	
	@IBOutlet weak var patientNameView: NSTextField!
	@IBOutlet weak var patientDOBView: NSTextField!
	@IBOutlet weak var currentDateView: NSTextField!
	@IBOutlet weak var mcPrimaryMatrix: NSMatrix!
	
	var labPrintVersion = String()
	var labNoteVersion = String()
	var addOnResult = Int()
    var currentPatient = PatientDataProfile()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        print(mcPrimaryMatrix.selectedCell()?.tag)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/YYYY"
		currentDateView.stringValue = dateFormatter.string(from: Date())
        patientNameView.stringValue = currentPatient.fullName
        patientDOBView.stringValue = currentPatient.dob
    }
    
    override func viewDidAppear() {
        print(currentPatient.insuranceList)
        if currentPatient.insurances.count > 0 && currentPatient.insurances[0].0.lowercased().contains("medicare") {
            print("Med prime")
            mcPrimaryMatrix.selectCell(withTag: 1)
        } else {
            print("Med not prime")
            mcPrimaryMatrix.selectCell(withTag: 0)
        }
        
    }
	
	
    @IBAction func printLab(_ sender: Any) {
        var mcPrimary = String()
        if mcPrimaryMatrix.selectedCell()!.tag == 1 {
            mcPrimary = "YES"
        } else if mcPrimaryMatrix.selectedCell()!.tag == 0 {
            mcPrimary = "NO"
        }
        var addOn = String()
        if addOnResult == 1 {
            addOn = "\n— ADD ON LAB —"
        }
        
        let labOrderOutputText = """
\(headerInfo)
Date: \(currentDateView.stringValue)
            
\(patientNameView.stringValue)     DOB: \(patientDOBView.stringValue) (\(currentPatient.age))
\(currentPatient.fullAddress)
Home: \(currentPatient.homePhone)
Mobile: \(currentPatient.mobilePhone)
            
INS      -      #
\(currentPatient.insuranceList)
            
M/C Primary: \(mcPrimary)
\(addOn)
            
TEST        -       DX CODE
\(labPrintVersion)
            
Dawn Whelchel, MD
            
\(labNoteVersion)
"""
        
        printLetterheadWithText(labOrderOutputText, fontSize: 11, window: self.view.window!, andCloseWindow: true)
    }
	
}
