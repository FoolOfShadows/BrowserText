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

protocol MedAndDiagnosisProtocol: class {
    var meds:[String] { get set }
    var diagnosis:[String] { get set }
}

class FormLettersVC: NSViewController {
    
    var theText = String()
    var currentPatient = PatientDataProfile()
    var lastNameID = String()
    
    weak var viewDataDelegate: webViewDataProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    var textHandler: () -> Void { return
    {
        self.theText = self.viewDataDelegate!.viewContent
        if !self.theText.contains(MissingData.MissingDataErrorMessage.ssn.rawValue) {
            MissingData().alertToMissingDataWithMessage(.needProfileTab, inWindow: self.view.window!)
        }
        }
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
//            let printHandler: ()->Void = {
//                print("Current patient: \(self.viewDataDelegate?.viewContent)")
//            }
            //viewDataDelegate?.getWebViewValueByID("ember3", dataType: "innerHTML", completion: printHandler)
        }
    }
    
    @IBAction func printNoShowLetter(_ sender: Any?) {
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        
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
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        
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
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        
        let creationHandler = {
            //print(self.currentPatient.firstName)
            self.performSegue(withIdentifier: "showBMDLetter", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openNHAdmitForm(_ sender: Any?) {
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        let creationHandler = {
            self.performSegue(withIdentifier: "showNHAdmit", sender: self)
        }
        
    }
    
    @IBAction func openDismissalLetter(_ sender: Any?) {
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        //print("Opening dismissal letters")
        let creationHandler = {
            self.performSegue(withIdentifier: "showDismissals", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openCollectionLetters(_ sender: Any?) {
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        //print("Opening collection letters")
        let creationHandler = {
            self.performSegue(withIdentifier: "showCollectionLetters", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openInsuranceProblemLetters(_ sender: Any?) {
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
        //print("Opening insurance problem letters")
        let creationHandler = {
            self.performSegue(withIdentifier: "showInsuranceProblemSegue", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func printReferral(_ sender: Any?) {
        viewDataDelegate?.getWebViewDataByID("ember3", completion: textHandler)
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
            //print("Opening BMD view?")
            if let toViewController = segue.destinationController as? BMDViewController {
                //print("Sending data: \(self.currentPatient.fullName)")
                toViewController.currentPatient = self.currentPatient
            }
        case "showNHAdmit":
            if let toViewController = segue.destinationController as? NHAdmitVC {
                toViewController.currentPatientData = ChartData(chartData: theText, aptTime: "", aptDate: 00)
            }
        case "showCollectionLetters":
            //print("Opening Collection Letters")
            if let toViewController = segue.destinationController as? CollectionLetterVC {
                //print("Sending data: \(self.currentPatient.fullName)")
                toViewController.currentPatient = self.currentPatient
            }
        case "showDismissals":
            if let toViewController = segue.destinationController as? DismissalLettersVC {
                //print("Sending data: \(self.currentPatient.fullName)")
                toViewController.currentPatient = self.currentPatient
            }
        case "showInsuranceProblemSegue":
            if let toViewController = segue.destinationController as? InsuranceProblemVC {
                //print("Sending data: \(self.currentPatient.fullName)")
                toViewController.currentPatient = self.currentPatient
            }
        default: return
        }
    }
    
    private func createPatientObject(withHandler handler: @escaping () -> Void) {
        var insNames = [String]()
        var insNumbers = [String]()
        //Get all the pieces of a patient's address
        //Field values don't get scraped when grabbing the text/HTML on a page and have to be accessed by the .value property
        let streetHandler: () -> Void = {
            //print("Street Data: \(self.viewDataDelegate!.viewContent)")
            self.currentPatient.street = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByClassName("address1", index: 0, completion: streetHandler)
        
        let cityStateZipHandler: () -> Void = {
            self.currentPatient.city = self.viewDataDelegate!.viewContent.components(separatedBy: ",")[0]
            self.currentPatient.zip = self.viewDataDelegate!.viewContent.components(separatedBy: " ").last!
        }
        viewDataDelegate?.getWebViewValueByClassName("city-state-zip", index: 0, completion: cityStateZipHandler)
//        let cityHandler: () -> Void = {
//            self.currentPatient.city = self.viewDataDelegate!.viewContent
//            //print("City Data: \(self.viewDataDelegate!.viewContent)")
//        }
//        viewDataDelegate?.getWebViewValueByID("city", dataType: "value", completion: cityHandler)
//
////        let stateHandler: () -> Void = {
////            self.currentPatient.state = self.viewDataDelegate!.viewContent
////        }
////        viewDataDelegate?.getWebViewValueByID("ember61922", dataType: "value", completion: stateHandler)
//
//        let zipHandler: () -> Void = {
//            self.currentPatient.zip = self.viewDataDelegate!.viewContent
//            //print("Zip Data: \(self.viewDataDelegate!.viewContent)")
//        }
//        viewDataDelegate?.getWebViewValueByID("zip-code", dataType: "value", completion: zipHandler)
        
        let dobHandler: () -> Void = {
            self.currentPatient.dob = self.viewDataDelegate!.viewContent
            //print("DOB Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByClassName("birth-date-text", index: 0, completion: dobHandler)
        
        let mobilePhoneHandler: () -> Void = {
            self.currentPatient.mobilePhone = self.viewDataDelegate!.viewContent
            //print("Mobile Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByClassName("phone-mobile", index: 0, completion: mobilePhoneHandler)
        
        let homePhoneHandler: () -> Void = {
            self.currentPatient.homePhone = self.viewDataDelegate!.viewContent
            //print("Home Data: \(self.viewDataDelegate!.viewContent)")
        }
        viewDataDelegate?.getWebViewValueByClassName("phone-home", index: 0, completion: homePhoneHandler)
        
        //Get all the pieces of a patient's name
        let fullNameHandler: () -> Void = {
            let patientFullName = self.viewDataDelegate!.viewContent
            let ptNameComponents = patientFullName.nameComponentsFromFullName()
            self.currentPatient.firstName = ptNameComponents.first
            self.currentPatient.lastName = ptNameComponents.last
            self.currentPatient.middleName = ptNameComponents.middle
            
        }
        viewDataDelegate?.getWebViewValueByClassName("full-name", index: 0, completion: fullNameHandler)
//        let firstNameHandler: () -> Void = {
//            self.currentPatient.firstName = self.viewDataDelegate!.viewContent
//            //print("First Name Data: \(self.viewDataDelegate!.viewContent)")
//        }
//        viewDataDelegate?.getWebViewValueByID("first-name", dataType: "value", completion: firstNameHandler)
//
//        let middleNameHandler: () -> Void = {
//            self.currentPatient.middleName = self.viewDataDelegate!.viewContent
//            //print("Middle Name Data: \(self.viewDataDelegate!.viewContent)")
//        }
//        viewDataDelegate?.getWebViewValueByID("middle-name", dataType: "value", completion: middleNameHandler)
//
//        //Getting the last name first requires getting the variable ID Practice Fusion is using for this value in the HTML, then getting the value based on that ID
//        let finishThisHandler: () -> Void = {
//            let lastNameHandler: () -> Void = {
//                self.currentPatient.lastName = self.viewDataDelegate!.viewContent
//                //print("Last Name Data: \(self.viewDataDelegate!.viewContent)")
//                handler()
//            }
//
//            self.viewDataDelegate?.getWebViewValueByID(self.lastNameID, dataType: "value", completion: lastNameHandler)
//        }
//
        //The insurances object is an array of tuples [(insName, insNumber)], ordered from primary to tertiary.  There are not more than three active ins at a time
        let insuranceNameHandler: () -> Void = {
            if let insuranceName = self.viewDataDelegate?.viewContent {
                print(insuranceName)
                if !insuranceName.removeWhiteSpace().isEmpty {
                    insNames.append(self.viewDataDelegate!.viewContent.replacingOccurrences(of: "|", with: ""))
                }
            }
        }
//        for index in 0...2 {
        viewDataDelegate?.getWebViewValueByClassName("payer-name", index: 0, completion: insuranceNameHandler)
        viewDataDelegate?.getWebViewValueByClassName("payer-name", index: 1, completion: insuranceNameHandler)
        viewDataDelegate?.getWebViewValueByClassName("payer-name", index: 2, completion: insuranceNameHandler)
//        }
        let insuranceNumberHandler: () -> Void = {
            if let insuranceNumber = self.viewDataDelegate?.viewContent {
                print(insuranceNumber)
                if !insuranceNumber.removeWhiteSpace().isEmpty {
                    insNumbers.append(self.viewDataDelegate!.viewContent.replacingOccurrences(of: "|", with: ""))
                }
            }
        }
//        for index in 0...2 {
        viewDataDelegate?.getWebViewValueByClassName("insured-id", index: 0, completion: insuranceNumberHandler)
        viewDataDelegate?.getWebViewValueByClassName("insured-id", index: 1, completion: insuranceNumberHandler)
        viewDataDelegate?.getWebViewValueByClassName("insured-id", index: 2, completion: insuranceNumberHandler)
//        }
        let finalHandler: () -> Void = {
            if insNumbers.count == insNames.count {
                var currentInsurances = [(String, String)]()
                for (count, item) in insNames.enumerated() {
                    currentInsurances.append((item.removeWhiteSpace(), insNumbers[count].removeWhiteSpace()))
                }
                self.currentPatient.insurances = currentInsurances
            }
            print(self.currentPatient.insurances)
            handler()
        }
        viewDataDelegate?.getWebViewValueByClassName("birth-date-text", index: 0, completion: finalHandler)

//        let lastNameIDHandler: () -> Void = {
//            //self.lastNameID = getEmberIDFromScrapedString(self.viewDataDelegate!.viewContent)
//            //print("Last Name ID: \(self.viewDataDelegate!.viewContent)")
//            self.currentPatient.insurances = getInsData(self.viewDataDelegate!.viewContent)
//            //finishThisHandler()
//        }
//        viewDataDelegate?.getWebViewValueByID("ember3", dataType: "innerHTML", completion: lastNameIDHandler)
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
    
    allIns = allIns.map { $0.findRegexMatchBetween("\"payer-name\">", and: "</a>")}
    allIDs = allIDs.map { $0.findRegexMatchBetween("-active\">", and: "</p>")}
    //print("Insurances: \(allIns)")
    //print("ID Numbers: \(allIDs)")
    for (count, item) in allIns.enumerated() {
        insData.append("\(item) - \(allIDs[count])")
        insTup.append((item, allIDs[count]))
    }
    //print(insTup)
    return insTup
}
