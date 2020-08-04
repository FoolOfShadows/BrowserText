//
//  InsuranceProblemVC.swift
//  BrowserText
//
//  Created by Fool on 2/28/20.
//  Copyright © 2020 Fool. All rights reserved.
//

import Cocoa

class InsuranceProblemVC: NSViewController {

    @IBOutlet weak var patientNameView: NSTextField!
    @IBOutlet weak var insuranceView: NSTextField!
    @IBOutlet weak var claimedPrimary: NSTextField!
    @IBOutlet weak var visitDateView: NSTextField!
    @IBOutlet weak var daysTilDue: NSTextField!
    
    var currentPatient = PatientDataProfile()
    
    weak var letterDelegate: LetterDataProtocol?
    weak var viewDataDelegate: webViewDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientNameView.stringValue = currentPatient.fullName
        if currentPatient.insurances.count < 0 {
            insuranceView.stringValue = currentPatient.insurances[0].0
        } else {
            insuranceView.stringValue = "No insurances currently active."
        }
        daysTilDue.stringValue = "14"
    }
    
    func printLetter(_ letter:String) {
        let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "LTRT", date: String(Date().shortDate()))
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithText(letter, window: self.view.window!, andCloseWindow: true)
    }
    
    @IBAction func printNotInEffect(_ sender: NSButton) {
        guard let dueDate =  Date().addingDays(Int(daysTilDue.stringValue)!)?.shortDate() else { return }
        let nieBody = """
    

\(currentDateLong())
        
        
\(currentPatient.fullName)
\(currentPatient.fullAddress)
        
        
Dear \(currentPatient.fullName),
        
We have been informed by \(insuranceView.stringValue) that your policy with them was not in effect for your visit on \(visitDateView.stringValue).
        
If you have other insurance which would have been in effect at the time of this visit, please bring proof of it to our office so we can bill the appropriate payer as soon as possible.  If we do not receive this information by \(dueDate) we regret we will have to bill you directly for any oustanding charges.
        
If you have any questions, please contact me at (903) 935-7101 extension 3.
        
Thank you for helping us resolve this matter.
        
Sincerely,
        
        
Donna Whelchel,
Accounts Manager
"""
        
        printLetter(nieBody)
    }
    
    @IBAction func printOtherInsurance(_ sender: NSButton) {
        guard let dueDate =  Date().addingDays(Int(daysTilDue.stringValue)!)?.shortDate() else { return }
        var oiMiddle = ""
        let oiHeader = """
\(currentDateLong())


\(currentPatient.fullName)
\(currentPatient.fullAddress)


Dear \(currentPatient.fullName),

"""
    if !claimedPrimary.stringValue.isEmpty {
        oiMiddle = """
We have been informed by \(insuranceView.stringValue) that your primary insurance provider is \(claimedPrimary.stringValue), therefore \(insuranceView.stringValue) is refusing to pay the claims submitted on your behalf.
        
Please bring a copy of the insurance card from \(claimedPrimary.stringValue) to our office so we can bill the appropraite payer as soon as possible.
"""
    } else {
        oiMiddle = """
We have been informed by \(insuranceView.stringValue) that they are not your primary insurance privider, therefore \(insuranceView.stringValue) is refusing to pay the claims submitted on your behalf.
        
Please bring a copy of the insurance card from your primary insurance provider to the office so we can bill the appropriate payer as soon as possible.
"""
        }
        
let oiFooter = """
If we do not receive the correct information by \(dueDate), we regret we will have to bill you directly for any outstanding charges.
        
If you have any questions, please contact me at (903) 935-7101 extension 3.
        
Thank you for helping us resolve this matter.
        
Sincerely,
        
        
Donna Whelchel,
Accounts Manager
"""
        
        let oiBody = "\(oiHeader)\n\(oiMiddle)\n\n\(oiFooter)"
        printLetter(oiBody)
    }
    
}
