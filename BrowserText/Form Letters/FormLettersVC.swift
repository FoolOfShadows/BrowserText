//
//  FormLettersVC.swift
//  BrowserText
//
//  Created by Fool on 6/7/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

protocol LetterDataProtocol: class {
    var patientData:PatientDataProfile { get set }
}

class FormLettersVC: NSViewController {
    
    var theText = String()
    var currentPatient = PatientDataProfile()
    var lastNameID = String()
    
    weak var viewDataDelegate: webViewDataProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let theWindow = self.view.window {
            theWindow.title = "Form Letters"
            //This removes the ability to resize the window of a view
            //opened by a segue
            theWindow.styleMask.remove(.resizable)
            //This makes the window float at the front of the other windows
            theWindow.level = .floating
            theWindow.setFrameUsingName("formLetterWindow")
            theWindow.windowController!.windowFrameAutosaveName = "formLetterWindow"
            let printHandler: ()->Void = {
                print("Current patient: \(self.viewDataDelegate?.viewContent)")
            }
            //viewDataDelegate?.getWebViewValueByID("ember3", dataType: "innerHTML", completion: printHandler)
        }
    }
    
    @IBAction func printNoShowLetter(_ sender: Any?) {
        let creationHandler = {
            printLetterheadWithText(createBasicLetterForPatient(self.currentPatient, withVerbiage:noShowVerbiage), fontSize: 14.0, window: self.view.window!)
            let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "NSRMNDR", date: String(Date().shortDate()))
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        }
        
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func printNeedAptLetter(_ sender: Any?) {
        let creationHandler = {
            printLetterheadWithText(createBasicLetterForPatient(self.currentPatient, withVerbiage:needAptVerbiage), fontSize: 14.0, window: self.view.window!)
            let fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "LTRT", date: String(Date().shortDate()))
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        }
        
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openBMDLetter(_ sender: Any?) {
        let creationHandler = {
            print(self.currentPatient.firstName)
            self.performSegue(withIdentifier: "showBMDLetter", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
        
    }
    
    @IBAction func printReferral(_ sender: Any?) {
        //let theCurrentDate = Date()
        //let labelDateFormatter = DateFormatter()
        //labelDateFormatter.dateFormat = "yyMMdd"
        //let labelVisitDate = labelDateFormatter.string(from: theCurrentDate)
        let creationHandler = {
            //printBlankPageWithText(createReferral(self.currentPatient), fontSize: 14.0, window: self.view.window!)
            //let saveLocation = ""
            var fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "REFERRAL", date: String(Date().shortDate()))
            fileName = "\(fileName).txt"
            let referralData = createReferral(self.currentPatient)
            if let referralFile = referralData.data(using: String.Encoding.utf8) {
                self.saveExportDialogWithData(referralFile, andFileName: fileName)
            }
//            let newFileManager = FileManager.default
//            let savePath = NSHomeDirectory()
//            newFileManager.createFile(atPath: "\(savePath)/Desktop/\(fileName)", contents: referralFile, attributes: nil)
        }
        
        createPatientObject(withHandler: creationHandler)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("Trying to segue")
        switch segue.identifier {
        case "showBMDLetter":
            print("Opening BMD view?")
            if let toViewController = segue.destinationController as? BMDViewController {
                print("Sending data: \(self.currentPatient.fullName)")
                toViewController.currentPatient = self.currentPatient
            }
        default: return
        }
    }
    
    func createPatientObject(withHandler handler: @escaping () -> Void) {
        //Get all the pieces of a patient's address
        //Field values don't get scraped when grabbing the text/HTML on a page and have to be accessed by the .value property
        let streetHandler: () -> Void = {
            print("Street Data: \(self.viewDataDelegate!.viewContent)")
            self.currentPatient.street = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByID("address-1", dataType: "value", completion: streetHandler)
        
        let cityHandler: () -> Void = {
            self.currentPatient.city = self.viewDataDelegate!.viewContent
            print("City Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("city", dataType: "value", completion: cityHandler)
        
//        let stateHandler: () -> Void = {
//            self.currentPatient.state = self.viewDataDelegate!.viewContent
//        }
//        viewDataDelegate?.getWebViewValueByID("ember61922", dataType: "value", completion: stateHandler)
        
        let zipHandler: () -> Void = {
            self.currentPatient.zip = self.viewDataDelegate!.viewContent
            print("Zip Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("zip-code", dataType: "value", completion: zipHandler)
        
        let dobHandler: () -> Void = {
            self.currentPatient.dob = self.viewDataDelegate!.viewContent
            print("DOB Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("birth-date", dataType: "value", completion: dobHandler)
        
        let mobilePhoneHandler: () -> Void = {
            self.currentPatient.mobilePhone = self.viewDataDelegate!.viewContent
            print("Mobile Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("mobile-phone", dataType: "value", completion: mobilePhoneHandler)
        
        let homePhoneHandler: () -> Void = {
            self.currentPatient.homePhone = self.viewDataDelegate!.viewContent
            print("Home Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("home-phone", dataType: "value", completion: homePhoneHandler)
        
        //Get all the pieces of a patient's name
        let firstNameHandler: () -> Void = {
            self.currentPatient.firstName = self.viewDataDelegate!.viewContent
            print("First Name Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("first-name", dataType: "value", completion: firstNameHandler)
        
        let middleNameHandler: () -> Void = {
            self.currentPatient.middleName = self.viewDataDelegate!.viewContent
            print("Middle Name Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByID("middle-name", dataType: "value", completion: middleNameHandler)
        
        //Getting the last name first requires getting the variable ID Practice Fusion is using for this value in the HTML, then getting the value based on that ID
        let finishThisHandler: () -> Void = {
            let lastNameHandler: () -> Void = {
                self.currentPatient.lastName = self.viewDataDelegate!.viewContent
                print("Last Name Data: \(self.viewDataDelegate!.viewContent)")
                handler()
            }
            
            self.viewDataDelegate?.getWebViewValueByID(self.lastNameID, dataType: "value", completion: lastNameHandler)
        }
        
        let lastNameIDHandler: () -> Void = {
            self.lastNameID = getEmberIDFromScrapedString(self.viewDataDelegate!.viewContent)
            print("Last Name ID: \(self.viewDataDelegate!.viewContent)")
            self.currentPatient.insurances = getInsData(self.viewDataDelegate!.viewContent)
            finishThisHandler()
        }
        viewDataDelegate?.getWebViewValueByID("ember3", dataType: "innerHTML", completion: lastNameIDHandler)
    }
    
    private func saveExportDialogWithData(_ data: Data, andFileName fileName: String) {
        let savePath = NSHomeDirectory()
        let saveLocation = "WPCMSharedFiles/zBertha Review/Referrals"
        
        let saveDialog = NSSavePanel()
        saveDialog.nameFieldStringValue = fileName
        saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
        //saveDialog.begin(completionHandler: {(result: NSApplication.ModalResponse) -> Void in
        saveDialog.beginSheetModal(for: self.view.window!, completionHandler: {(result: NSApplication.ModalResponse) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let filePath = saveDialog.url {
                    if let path = URL(string: String(describing: filePath)) {
                        do {
                            try data.write(to: path, options: .withoutOverwriting)
                            //This is where we can close the spawning window if the save is successful
                            //self.closeTheWindow()
                        } catch {
                            let alert = NSAlert()
                            alert.messageText = "There is already a file with this name.\n Please choose a different name."
                            alert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                                let returnCode = NSModalResponse
                                print(returnCode)
                            }
                        }
                    }
                }
                
            }})
    }
}

func getInsData(_ data:String) -> [(String, String)] {
    //print("Data:  \(data)")
    var insData = [String]()
    var insTup = [(String, String)]()
    var allIns = data.allRegexMatchesFor("\"payer-name\">.*?</a>")
    var allIDs = data.allRegexMatchesFor("md ember-view\">\\s.*?<p.*?</p>")
    
    allIns = allIns.map { $0.findRegexMatchBetween("\"payer-name\">", and: "</a>")!}
    allIDs = allIDs.map { $0.findRegexMatchBetween("-active\">", and: "</p>")!}
    print("Insurances: \(allIns)")
    print("ID Numbers: \(allIDs)")
    for (count, item) in allIns.enumerated() {
        insData.append("\(item) - \(allIDs[count])")
        insTup.append((item, allIDs[count]))
    }
    print(insTup)
    return insTup
}
