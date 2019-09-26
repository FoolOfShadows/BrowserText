//
//  MainVC.swift
//  PhoneMessages
//
//  Created by Fool on 3/6/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

protocol scriptTableDelegate: class {
    func currentMedsWillBeDismissed(sender: PMCurrentMedsController)
}

protocol symptomsDelegate: class {
    func symptomsSelectionWillBeDismissed(sender: PMSymptomsController)
}

class PhoneMessageVC: NSViewController, scriptTableDelegate, symptomsDelegate, NSComboBoxDelegate {

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
    
    var currentMessageText:Message = Message(theText: String())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("PM View loading")
        //clearMessage(self)
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
                let theAlert = NSAlert()
                theAlert.messageText = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
                theAlert.beginSheetModal(for: theWindow) { (NSModalResponse) -> Void in
                    let returnCode = NSModalResponse
                    print(returnCode)}
            }
        }
        
        currentMessageText = Message(theText: patientData)
        dateView.stringValue = currentMessageText.messageDate
        nameView.stringValue = currentMessageText.ptInnerName
        dobView.stringValue = currentMessageText.ptDOB
        phoneView.stringValue = currentMessageText.phone
        //lastEncounterView.stringValue = currentMessageText.lastAppointment
        allergiesView.string = currentMessageText.allergies
        medicationString = currentMessageText.medicines
        messageView.string = "Last apt: \(currentMessageText.lastAppointment) - Next apt: \(currentMessageText.nextAppointment)"
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
        let messageText = "\(dateView.stringValue)\n\(nameView.stringValue) (DOB: \(dobView.stringValue))\n\(phoneView.stringValue)\(callingOnBehalf)\n\(pharmacyCombo.stringValue)\n\nMESSAGE:\n\(messageView.string)\n\nRESPONSE:\(allergySelection)"
        guard let fileTextData = messageText.data(using: String.Encoding.utf8) else { return }
        saveExportDialogWithData(fileTextData, andFileExtension: ".txt")
        //lastMessageView.stringValue = currentMessageText.ptLabelName
        self.view.window?.performClose(self)
    }
    
    
    func saveExportDialogWithData(_ data: Data, andFileExtension ext: String) {
        let savePath = NSHomeDirectory()
        let saveLocation = "WPCMSharedFiles"
        
        let saveDialog = NSSavePanel()
        saveDialog.nameFieldStringValue = "\(currentMessageText.ptLabelName) PMSG \(currentMessageText.labelDate)"
        saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
        //saveDialog.begin(completionHandler: {(result: NSApplication.ModalResponse) -> Void in
        saveDialog.beginSheetModal(for: self.view.window!, completionHandler: {(result: NSApplication.ModalResponse) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let filePath = saveDialog.url {
                    if let path = URL(string: String(describing: filePath) + ext) {
                        do {
                            try data.write(to: path, options: .withoutOverwriting)
                            //This is where we can close the spawning window if the save is successful
                            self.closeTheWindow()
                        } catch {
                            let alert = NSAlert()
                            alert.messageText = "There is already a file with this name.\n Please choose a different name."
                            alert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                                let returnCode = NSModalResponse
                                print(returnCode)
                            }
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
   
//    func comboBoxSelectionIsChanging(_ notification: Notification) {
//        let comboBox = notification.object as! NSComboBox
//        switch comboBox {
//        case schedulingCombo:
//            print("Scheduling value: \(schedulingCombo.stringValue)")
//            if !schedulingCombo.stringValue.isEmpty {
//                print("Scheduling not empty")
//                let newSymptom = "Patient requesting scheduling update for \(schedulingCombo.stringValue)"
//                messageView.string += "\n\(newSymptom)"
//            }
//        case resultsCombo:
//            print("Results")
//            if !resultsCombo.stringValue.isEmpty {
//                let newSymptom = "Patient requesting results of \(resultsCombo.stringValue)"
//                messageView.string += "\n\(newSymptom)"
//            }
//        default:
//            return
//        }
//    }
    
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
        //self.view.window?.isReleasedWhenClosed = true
        self.view.window?.performClose(sender)
    }
    
    
}
