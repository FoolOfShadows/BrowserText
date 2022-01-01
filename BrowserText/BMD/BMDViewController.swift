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
    
    var currentPatient = PatientDataProfile()
    
    weak var letterDelegate: LetterDataProtocol?
    weak var viewDataDelegate: webViewDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        currentDateView.stringValue = currentDateLong()
        ptNameView.stringValue = currentPatient.fullName
        print(currentPatient.fullAddress)
    }
    
    @IBAction func clearBMD(_ sender: Any) {
    }
    
    @IBAction func processBMD(_ sender: Any) {
        
        let currentBMD = BMDData(ptName:ptNameView.stringValue, ltrDate:currentDateView.stringValue, testDate:testDateView.stringValue, tScore:tScoreView.doubleValue, location:locationView.stringValue, address: currentPatient.fullAddress)
        
        let fileName = createFileLabelFrom(PatientName: currentPatient.labelName, FileType: "BMD", date: currentDateView.stringValue)
        
        //Pass the final letter string to the clipboard
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithRichText(currentBMD.generateOutput(), fontSize: 14.0, window: self.view.window!, andCloseWindow: true)
    }
    
}
