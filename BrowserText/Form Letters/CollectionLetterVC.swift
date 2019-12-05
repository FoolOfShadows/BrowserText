//
//  CollectionLetterVC.swift
//  BrowserText
//
//  Created by Fool on 12/5/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

class CollectionLetterVC: NSViewController {
    
    @IBOutlet weak var patientNameView: NSTextField!
    @IBOutlet weak var amountDueView: NSTextField!
    @IBOutlet weak var firstLetterDateView: NSTextField!
    @IBOutlet weak var secondLetterDateView: NSTextField!
    @IBOutlet weak var daysTilDue: NSTextField!
    
    var currentPatient = PatientDataProfile()
    
    weak var letterDelegate: LetterDataProtocol?
    weak var viewDataDelegate: webViewDataProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        patientNameView.stringValue = currentPatient.fullName
    }
    
    @IBAction func printCL1(_ sender: NSButton) {
        let cl1Body = """
        
        \(currentDateLong())
        
        
        
        \(currentPatient.fullName)
        \(currentPatient.fullAddress)
        
        
        
        Dear \(currentPatient.fullName),
        
        You currently have an outstanding balance of \(amountDueView.stringValue) with our office.  Our policy requires that all balances be paid in full upon receipt of statement.  Please remit payment for the balance due on your account immediately.
        
        \(cl1End)
        """
        let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "CL1", date: String(Date().shortDate()))
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithText(cl1Body, window: self.view.window!, andCloseWindow: true)
    }
    
    @IBAction func printCL2(_ sender: NSButton) {
        guard let dueDate =  Date().addingDays(Int(daysTilDue.stringValue)!)?.shortDate() else { return }
        let cl2Body = """
        
        \(currentDateLong())
        
        
        
        \(currentPatient.fullName)
        \(currentPatient.fullAddress)
        
        
        
        Dear \(currentPatient.fullName),
        
        We contacted you on \(firstLetterDateView.stringValue) regarding your outstanding balance of \(amountDueView.stringValue), but have not heard back.  Please call us immediately at 903-935-7101 x3 to settle your account, set up a payment plan, or account for why you have not paid us.  If you do not contact us by \(dueDate) to settle your account, we may send it to a collection agency and terminate the availability of our services to you.
        
        If you have any questions please contact me at (903) 935-7101 X 3.
        
        Sincerely,
        
        
        Donna Whelchel
        Accounts Manager
        """
        
        let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "CL2", date: String(Date().shortDate()))
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithText(cl2Body, window: self.view.window!, andCloseWindow: true)
    }
    
    @IBAction func printCL3(_ sender: NSButton) {
        guard let dueDate =  Date().addingDays(Int(daysTilDue.stringValue)!)?.shortDate() else { return }
        let cl3Body = """
        
        \(currentDateLong())
        
        
        
        \(currentPatient.fullName)
        \(currentPatient.fullAddress)
        
        
        
        Dear \(currentPatient.fullName),
        
        As per our letters of \(firstLetterDateView.stringValue) and \(secondLetterDateView.stringValue) sent to you at the above address, your account with us is over-due in the amount of \(amountDueView.stringValue).  Unless your account is paid in full by \(dueDate), we regret that we must take the following actions:

             1. Your account will be turned over to a collection agency.
             2. We will terminate the availability of our services to you.

        Our financial policy was provided to you and acknowledged by you with your signature at the time you became a patient in our practice.
        
        If you have any questions please contact me at (903) 935-7101 X 3.
        
        Sincerely,
        
        
        Donna Whelchel
        Accounts Manager
        """
        
        let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "CL3", date: String(Date().shortDate()))
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithText(cl3Body, window: self.view.window!, andCloseWindow: true)
    }
    
}
