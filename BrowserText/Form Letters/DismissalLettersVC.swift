//
//  DismissalLettersVC.swift
//  BrowserText
//
//  Created by Fool on 12/5/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

class DismissalLettersVC: NSViewController {

    @IBOutlet weak var nameView: NSTextField!
    @IBOutlet weak var dateView: NSTextField!
    @IBOutlet weak var typeStackView: NSStackView!
    
    var dismissalType = DismissalType.nonSpecific
    
    var currentPatient = PatientDataProfile()
    
//    weak var letterDelegate: LetterDataProtocol?
//    weak var viewDataDelegate: webViewDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        nameView.stringValue = currentPatient.fullName
        dateView.stringValue = currentDateLong()
    }
    @IBAction func setDismissalType(_ sender: NSButton) {
        if let type = DismissalType.init(rawValue: sender.title) {
            dismissalType = type
        }
        print(dismissalType)
    }
    
    @IBAction func printDismissalLetter(_ sender: Any) {
        func reason() -> String {
            switch self.dismissalType {
            case .nonSpecific:
                return dsmslNonSpecific
            case .missedApt:
                return dsmslMissedApts
            case .nonPayment:
                return dsmslNonPayment
            case .tag:
                return dsmslTAG
            case .paymentArrangement:
                return dsmslPayemntArrangement
            case .nonCompliance:
                return dsmslNonCompliance
            case .nsf:
                return dsmslNSF
            }
        }
        
        let dismissalLetter = """

\(dateView.stringValue)
     
        
CERTIFIED MAIL - RETURN RECEIPT REQUESTED
     
        
\(currentPatient.fullName)
\(currentPatient.fullAddress)
       
       
       
Dear \(currentPatient.fullName),
        
\(reason())
        
\(dsmslBody)
"""
        
        let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "DSMSL", date: String(Date().shortDate()))
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithText(dismissalLetter, window: self.view.window!, andCloseWindow: true)
    }
    
    
}

enum DismissalType:String {
    case nonSpecific = "Non-specific"
    case missedApt = "Missed appointments"
    case nonPayment = "Non-payment"
    case tag = "TAG"
    case nsf = "NSF"
    case nonCompliance = "Non-compliance"
    case paymentArrangement = "Payment arrangement"
}
