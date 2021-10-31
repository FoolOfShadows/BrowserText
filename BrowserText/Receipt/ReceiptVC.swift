//
//  ReceiptVC.swift
//  BrowserText
//
//  Created by Fool on 7/15/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

class ReceiptVC: NSViewController {

    
    @IBOutlet weak var ptName: NSTextField!
    @IBOutlet weak var date: NSTextField!
    @IBOutlet weak var amount: NSTextField!
    @IBOutlet weak var methodStack: NSStackView!
    @IBOutlet weak var reasonStack: NSStackView!
    @IBOutlet weak var reasonText: NSTextField!
    //@IBOutlet weak var reasonCombo: NSComboBox!
    @IBOutlet weak var processorCombo: NSComboBox!
    @IBOutlet weak var notesScrollView: NSScrollView!
    @IBOutlet weak var checkNumberView: NSTextField!
    @IBOutlet weak var checkCheckBox: NSButton!
    
    
    
    weak var viewDataDelegate: webViewDataProtocol?
    var patientData = String()
    var currentReceipt = Receipt(theText: "")
    
    var noteView:NSTextView {
        get {
            return notesScrollView.contentView.documentView as! NSTextView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let theWindow = self.view.window {
            theWindow.title = "Receipt"
            //This removes the ability to resize the window of a view
            //opened by a segue
            theWindow.styleMask.remove(.resizable)
            //This makes the window float at the front of the other windows
            //Does the staff want this window to float? - no 5/23/19
            theWindow.level = .floating
            theWindow.setFrameUsingName("receipt")
            theWindow.windowController!.windowFrameAutosaveName = "receipt"
            startNewReceipt()
//            reasonCombo.clearComboBox(menuItems: currentReceipt.reasonChoices)
            processorCombo.clearComboBox(menuItems: currentReceipt.processorChoices)
        }
    }
    
    @IBAction func printReceipt(_ sender: Any) {
        if ptName.stringValue == "" {
            errorNotification(self.view, withMessage: "Patient name cannot be blank")
        } else if methodStack.getActiveButtonInView() == "" {
            errorNotification(self.view, withMessage: "Failed to select the method of payment")
        } else if checkCheckBox.state == .on && checkNumberView.stringValue.isEmpty {
            errorNotification(self.view, withMessage: "Check number cannot be blank when accepting a check")
        } else if reasonStack.getActiveButtonsInView().count == 0 && reasonText.stringValue.isEmpty {
            errorNotification(self.view, withMessage: "Failed to select the reason for payment")
        } else if amount.stringValue.isEmpty {
            errorNotification(self.view, withMessage: "Failed to enter the amount of the payment")
        } else if processorCombo.stringValue.isEmpty {
            errorNotification(self.view, withMessage: "Failed to enter the payment processor")
        } else {
        
        let receiptText = createReceipt()
        
        //Generate text file receipt for billing
        let fileName = "\(currentReceipt.ptLabelName) RECEIPT \(currentReceipt.labelDate) \(currentReceipt.labelTime).txt"
        
        let receiptData = receiptText.data(using: String.Encoding.utf8)
        let newFileManager = FileManager.default
        let savePath = NSHomeDirectory()
            newFileManager.createFile(atPath: "\(savePath)/\(FilePath.baseFolder.rawValue)/\(FilePath.receipts.rawValue)/\(fileName)", contents: receiptData, attributes: nil)
        
        //Print receipt on letter head for patient
            printLetterheadWithText(receiptText, window: self.view.window!, andCloseWindow: true, defaultCopies: 2)
        }
    }
    
    func startNewReceipt() {
        currentReceipt = Receipt(theText: patientData)
        ptName.stringValue = currentReceipt.ptInnerName
        date.stringValue = currentReceipt.messageDate
        
    }
    
    func createReceipt() -> String {
        var receiptText = String()
        var noteText = String()
        var checkNumber = String()
        
        if !noteView.string.isEmpty {
            noteText = "NOTE: \(noteView.string)"
        }
        if !checkNumberView.stringValue.isEmpty {
            checkNumber = " (#\(checkNumberView.stringValue))"
        }
        
        let methodOfPayment = methodStack.getActiveButtonInView()
        
        var paymentReasons = reasonStack.getActiveButtonsInView()
        if !reasonText.stringValue.isEmpty {
            paymentReasons.append(reasonText.stringValue)
        }
        
        let reasonForPayment = paymentReasons.joined(separator: ", ")
        
        receiptText = """
        
        
        
        PAYMENT RECEIPT      \(date.stringValue)

        \(ptName.stringValue)
        
        $\(amount.stringValue.replacingOccurrences(of: "$", with: ""))     \(methodOfPayment)\(checkNumber)
        
        Paying for: \(reasonForPayment)
        
        Processed by: \(processorCombo.stringValue)
        
        \(noteText)
"""
        
        return receiptText
    }
    
    func errorNotification(_ view: NSView, withMessage message: String) {
        guard let theWindow = view.window else { return }
        let theAlert = NSAlert()
        theAlert.messageText = message
        theAlert.beginSheetModal(for: theWindow) { (NSModalResponse) -> Void in
            let returnCode = NSModalResponse
            print(returnCode)
            
        }
    }
    
    @IBAction func activateOtherField(_ sender: NSButton) {
        if sender.state == .on {
            reasonText.isEnabled = true
        } else {
            reasonText.stringValue = String()
            reasonText.isEnabled = false
        }
    }
    
    @IBAction func selectAmount(_ sender: NSButton) {
        amount.stringValue = "\(sender.title).00"
        if let buttons = sender.superview?.subviews as? [NSButton] {
            for button in buttons {
                if button.title != sender.title {
                    button.state = .off
                }
            }
        }
    }
    
    @IBAction func selectOnlyOne(_ sender: NSButton) {
        if let buttons = sender.superview?.subviews as? [NSButton] {
            for button in buttons {
                if button.title != sender.title {
                    button.state = .off
                    if sender.title == "Check" {
                        checkNumberView.isEnabled = true
                    } else {
                        checkNumberView.stringValue = String()
                        checkNumberView.isEnabled = false
                    }
                }
            }
        }
    }
}
