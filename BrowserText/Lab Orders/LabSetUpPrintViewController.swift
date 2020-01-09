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
//    var ptName = String()
//    var ptDOB = String()
//    var fileLabelName = String()
    
//    var medicare:Int = 0
	
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
        
        printLetterheadWithText(labOrderOutputText, fontSize: 14, window: self.view.window!, andCloseWindow: true)
//        //Create a view to hold the final text so it can be passed to the NSPrintOperation
//        let printView = NSTextView()
//        //Set the size of the view or the text won't appear on the page
//        printView.setFrameSize(NSSize(width: 680, height: 0))
//        //Transfer the final string to the TextView's string property
//        printView.string = labOrderOutputText
//        //printView.sizeToFit()
//        //print(printView.string)
//        let printInfo = NSPrintInfo.shared
//        //printInfo.orientation = .portrait
//        //printInfo.verticalPagination = .autoPagination
//        printInfo.leftMargin = 40
//        //printInfo.rightMargin = 20
//        //printInfo.isHorizontallyCentered = false
//        printInfo.isVerticallyCentered = false
//        //printInfo.topMargin = 0
//        printInfo.bottomMargin = 40
//        let operation: NSPrintOperation = NSPrintOperation(view: printView, printInfo: printInfo)
//        operation.run()
        
        //self.view.window?.close()
    }
	
}
