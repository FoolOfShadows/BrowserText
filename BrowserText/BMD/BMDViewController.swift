//
//  BMDViewController.swift
//  Form Letters
//
//  Created by Fool on 11/15/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

class BMDViewController: NSViewController {
    @IBOutlet weak var ptNameView: NSTextField!
    @IBOutlet weak var currentDateView: NSTextField!
    @IBOutlet weak var testDateView: NSTextField!
    @IBOutlet weak var tScoreView: NSTextField!
    @IBOutlet weak var locationView: NSTextField!
    @IBOutlet weak var dxView: NSTextField!
    
    //var patientData = PatientDataForLetters(theText: "")
    var currentPatient = PatientDataProfile()
    
    weak var letterDelegate: LetterDataProtocol?
    weak var viewDataDelegate: webViewDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //print("Loading BMD view")
        currentDateView.stringValue = currentDateLong()
        //print("Data for patient: \(patientData.ptInnerName)")
        ptNameView.stringValue = currentPatient.fullName
        print(currentPatient.fullAddress)
    }
    
    @IBAction func clearBMD(_ sender: Any) {
    }
    
    @IBAction func processBMD(_ sender: Any) {
        
        let currentBMD = BMDData(ptName:ptNameView.stringValue, ltrDate:currentDateView.stringValue, testDate:testDateView.stringValue, tScore:tScoreView.doubleValue, location:locationView.stringValue, address: currentPatient.fullAddress)
        
        //Pass the final letter string to the clipboard
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(currentBMD.generateOutput(), forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithText(currentBMD.generateOutput(), fontSize: 14.0, window: self.view.window!)
        dismiss(self)
        
    }
    
}
