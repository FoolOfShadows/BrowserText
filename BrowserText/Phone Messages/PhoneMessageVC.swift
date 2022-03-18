//
//  MainVC.swift
//  PhoneMessages
//
//  Created by Fool on 3/6/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

protocol scriptTableDelegate: AnyObject {
    func currentMedsWillBeDismissed(sender: PMCurrentMedsController)
}

protocol symptomsDelegate: AnyObject {
    func symptomsSelectionWillBeDismissed(sender: PMSymptomsController)
}

class PhoneMessageVC: NSViewController, scriptTableDelegate, symptomsDelegate, NSComboBoxDelegate, NSOpenSavePanelDelegate {

    @IBOutlet weak var dateView: NSTextField!
    @IBOutlet weak var nameView: NSTextField!
    @IBOutlet weak var dobView: NSTextField!
    @IBOutlet weak var phoneView: NSTextField!
    @IBOutlet weak var pharmacyCombo: NSComboBox!
    @IBOutlet weak var onBehalfView: NSTextField!
    
    @IBOutlet weak var allergiesScroll: NSScrollView!
    @IBOutlet weak var messageScroll: NSScrollView!
    @IBOutlet weak var includeAllergiesCheckbox: NSButton!
    @IBOutlet weak var resultsCombo: NSComboBox!
    @IBOutlet weak var schedulingCombo: NSComboBox!
    
    @IBOutlet weak var lastMessageView: NSTextField!
    
    @IBOutlet weak var startNewMessageButton: NSButton!
    
    @IBOutlet weak var pmsgView: NSView!
    
    //For some reason the program crashes on B's MacBook if I try to connect
    //these NSTextViews direct to their outlets in IB
    var allergiesView: NSTextView {
        get {
            return allergiesScroll.contentView.documentView as! NSTextView
        }
    }
    
    var messageView: NSTextView {
        get {
            return messageScroll.contentView.documentView as! NSTextView
        }
    }
    
    var medicationString = String()
    var wantedMeds = [String]()
    var notedSymptoms = [String]()
    
    var patientData = String()
    var viewDataDelegate: webViewDataProtocol?
    
    var currentMessageText:Message = Message(theText: String())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allergiesView.font = NSFont.systemFont(ofSize: 18)
        messageView.font = NSFont.systemFont(ofSize: 18)
        self.resultsCombo.delegate = self
        self.schedulingCombo.delegate = self
    }
    
    //The call to startNewMessage needs to be here rather than viewDidLoad to work
    override func viewDidAppear() {
        super.viewDidAppear()
        if let theWindow = self.view.window {
            theWindow.title = "Phone Message"
            //This removes the ability to resize the window of a view
            //opened by a segue
            theWindow.styleMask.remove(.resizable)
            //This makes the window float at the front of the other windows
            //Does the staff want this window to float? - no 5/23/19
            //theWindow.level = .floating
            theWindow.setFrameUsingName("phoneMessageWindow")
            theWindow.windowController!.windowFrameAutosaveName = "phoneMessageWindow"
        }
        startNewMessage(self)
    }
    
    @IBAction func startNewMessage(_ sender: Any) {
        guard let theWindow = self.view.window else { return }
        clearMessage(self)
        //Get the clipboard to process
//        let pasteBoard = NSPasteboard.general
//        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        if checkForICD10(patientData, window: theWindow) == true {
            if !patientData.contains("Flowsheets") {
                //Create an alert to let the user know the clipboard doesn't contain
                //the correct PF data
                print("You broke it!")
                //After notifying the user, break out of the program
                MissingData().alertToMissingDataWithMessage(.correctBits, inWindow: theWindow)
            }
        }
        
        currentMessageText = Message(theText: patientData)
        let employeeNameHandler: () -> Void = {
            print("VIEW CONTENT: \(self.viewDataDelegate!.viewContent)")
            self.currentMessageText.employee = self.viewDataDelegate!.viewContent.cleanTheTextOf(employeeNameBadBits)
            self.dateView.stringValue = self.currentMessageText.messageDate
            self.nameView.stringValue = self.currentMessageText.ptInnerName
            self.dobView.stringValue = self.currentMessageText.ptDOB
            self.phoneView.stringValue = self.currentMessageText.phone
            self.allergiesView.string = self.currentMessageText.allergies
            self.medicationString = self.currentMessageText.medicines
            self.messageView.string = "Message taken by: \(self.currentMessageText.employee)\nLast apt: \(self.currentMessageText.lastAppointment) - Next apt: \(self.currentMessageText.nextAppointment)"
        }
        self.viewDataDelegate?.getWebViewValueByClassName("provider-name", index: 0, completion: employeeNameHandler)
        print("EMPLOYEE NAME: \(self.currentMessageText.employee)")
    }
    
    @IBAction func getMeds(_ sender: Any) {
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrentMeds" {
            if let toViewController = segue.destinationController as? PMCurrentMedsController {
                //For the delegate to work, it needs to be assigned here
                //rather than in view did load.  Because it's a modal window?
                toViewController.medReloadDelegate = self
                toViewController.medicationsString = medicationString
            }
        } else if segue.identifier == "showSymptoms" {
            if let toViewController = segue.destinationController as? PMSymptomsController {
                toViewController.symptomDelegate = self
                toViewController.selectedSymptoms = [String]()
            }
        }
    }
    
    @IBAction func saveFile(_ sender: Any) {
        var allergySelection = String()
        var callingOnBehalf = String()
        
        if !onBehalfView.stringValue.isEmpty {
            callingOnBehalf =  "\nContact: \(onBehalfView.stringValue)"
        }
        if includeAllergiesCheckbox.state == .on {
            allergySelection = "\n\n\nALLERGIES:\n\(allergiesView.string)"
        }
        let messageText = "\(dateView.stringValue)\n\(nameView.stringValue) (DOB: \(dobView.stringValue))\n\(phoneView.stringValue)\(callingOnBehalf)\n\(pharmacyCombo.stringValue)\n\nMESSAGE:\n\(messageView.string)\n\nRESEARCH:\n\nRESPONSE:\(allergySelection)"
        guard let fileTextData = messageText.data(using: String.Encoding.utf8) else { return }
        saveExportDialogWithData(fileTextData, andFileExtension: ".txt")
    }
    
    
    private func saveExportDialogWithData(_ data: Data, andFileExtension ext: String) {
        let savePath = NSHomeDirectory()
        let saveLocation = FilePath.baseFolder.rawValue
        
        let saveDialog = NSSavePanel()
        saveDialog.nameFieldStringValue = "\(currentMessageText.ptLabelName) PMSG \(currentMessageText.labelDate)"
        saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
        saveDialog.beginSheetModal(for: self.view.window!, completionHandler: {(result: NSApplication.ModalResponse) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let filePath = saveDialog.url {
                    if let path = URL(string: String(describing: filePath) + ext) {
                        do {
                            try data.write(to: path, options: .withoutOverwriting)
                            //This is where we can close the spawning window if the save is successful
                            self.closeTheWindow()
                        } catch {
                            MissingData().alertToMissingDataWithMessage(.existingFile, inWindow: self.view.window!)
                        }
                        if let thePath = path.absoluteString.removingPercentEncoding {
                            self.lastMessageView.stringValue = thePath
                        }
                    }
                }
                
            }})
    }
    
    private func closeTheWindow() {
        //To close the window with the current design, I needed a specific outlet to the view so I could track back to it's window and tell it to close
        pmsgView.window!.close()
    }
    
    @IBAction func clearMessage(_ sender: Any) {
        self.view.clearControllers()
        includeAllergiesCheckbox.state = .on
        currentMessageText = Message(theText: String())
        wantedMeds = [String]()
        schedulingCombo.clearComboBox(menuItems: resultsList)
        pharmacyCombo.clearComboBox(menuItems: pharmacies)
        resultsCombo.clearComboBox(menuItems: resultsList)
    }
    
    func currentMedsWillBeDismissed(sender: PMCurrentMedsController) {
        if messageView.string.isEmpty {
        messageView.string = "REQUESTED REFILLS:\n\(wantedMeds.joined(separator: "\n"))"
        } else {
            messageView.string += "\n\nREQUESTED REFILLS:\n\(wantedMeds.joined(separator: "\n"))"
        }
    }
    
    func symptomsSelectionWillBeDismissed(sender: PMSymptomsController) {
        if !notedSymptoms.isEmpty {
        if messageView.string.isEmpty {
            messageView.string = "SYMPTOMS:\n\(notedSymptoms.joined(separator: ", "))"
        } else {
            messageView.string += "\n\nSYMPTOMS:\n\(notedSymptoms.joined(separator: ", "))"
        }
        }
    }
    
    @IBAction func addSymptom(_ sender: NSButton) {
        let newSymptom = sender.title
            if sender.state == .on {
                if messageView.string.isEmpty {
                    messageView.string = newSymptom
                } else {
                    messageView.string += "\n\(newSymptom)"
                }
            } else if sender.state == .off {
                messageView.string = messageView.string.replacingOccurrences(of: "\n\(newSymptom)", with: "")
            }
        }
    
    @IBAction func addResultRequest(_ sender: NSComboBox) {
        if !sender.stringValue.isEmpty {
            let newSymptom = "Patient requesting results of \(sender.stringValue)."
            if messageView.string.isEmpty {
                messageView.string = newSymptom
            } else {
                messageView.string += "\n\(newSymptom)"
            }
            sender.selectItem(at: 0)
        }
    }

    @IBAction func addSchedulingRequest(_ sender: NSComboBox) {
        if !sender.stringValue.isEmpty {
            let newSymptom = "Patient requesting scheduling update for \(sender.stringValue)."
            if messageView.string.isEmpty {
                messageView.string = newSymptom
            } else {
                messageView.string += "\n\(newSymptom)"
            }
            sender.selectItem(at: 0)
        }
    }
    
    //FIXME: Not sure I need this button and action anymore as the
    //window can be closed with its close button
    @IBAction func closePMSGView(_ sender: Any) {
        self.view.window?.performClose(sender)
    }
    
    
}
