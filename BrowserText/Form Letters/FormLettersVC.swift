//
//  FormLettersVC.swift
//  BrowserText
//
//  Created by Fool on 6/7/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

protocol LetterDataProtocol: AnyObject {
    var patientData:PatientDataProfile { get set }
}

protocol MedAndDiagnosisProtocol: AnyObject {
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
        }
    }
    
    @IBAction func printNoShowLetter(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        
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
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        
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
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        
        let creationHandler = {
            self.performSegue(withIdentifier: "showBMDLetter", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openGeneralLetter(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        
        let creationHandler = {
            self.performSegue(withIdentifier: "showGeneralLetter", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openNHAdmitForm(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        let creationHandler = {
            self.performSegue(withIdentifier: "showNHAdmit", sender: self)
        }
        
    }
    
    @IBAction func openDismissalLetter(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        let creationHandler = {
            self.performSegue(withIdentifier: "showDismissals", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openCollectionLetters(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        let creationHandler = {
            self.performSegue(withIdentifier: "showCollectionLetters", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func openInsuranceProblemLetters(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)
        let creationHandler = {
            self.performSegue(withIdentifier: "showInsuranceProblemSegue", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    @IBAction func printReferral(_ sender: Any?) {
        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: textHandler)

        let creationHandler = {
            var fileName = createFileLabelFrom(PatientName: getFileLabellingNameFrom(self.currentPatient.fullName, ofType: FileLabelType.full), FileType: "REFERRAL", date: String(Date().shortDate()))
            fileName = "\(fileName).txt"
            let referralData = createReferral(self.currentPatient)
            if let referralFile = referralData.data(using: String.Encoding.utf8) {
                self.saveExportDialogWithData(referralFile, andFileName: fileName)
            }
        }
        
        createPatientObject(withHandler: creationHandler)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("Trying to segue")
        switch segue.identifier {
        case "showBMDLetter":
            if let toViewController = segue.destinationController as? BMDViewController {
                toViewController.currentPatient = self.currentPatient
            }
        case "showGeneralLetter":
            if let toViewController = segue.destinationController as? GeneralLetterVC {
                toViewController.currentPatient = self.currentPatient
            }
        case "showNHAdmit":
            if let toViewController = segue.destinationController as? NHAdmitVC {
                toViewController.currentPatientData = ChartData(chartData: theText, aptTime: "", aptDate: 00)
            }
        case "showCollectionLetters":
            if let toViewController = segue.destinationController as? CollectionLetterVC {
                toViewController.currentPatient = self.currentPatient
            }
        case "showDismissals":
            if let toViewController = segue.destinationController as? DismissalLettersVC {
                toViewController.currentPatient = self.currentPatient
            }
        case "showInsuranceProblemSegue":
            if let toViewController = segue.destinationController as? InsuranceProblemVC {
                toViewController.currentPatient = self.currentPatient
            }
        default: return
        }
    }
    
    //MARK: Create Patient Object
    private func createPatientObject(withHandler handler: @escaping () -> Void) {
        var insNames = [String]()
        var insNumbers = [String]()
        //Get all the pieces of a patient's address
        let streetHandler: () -> Void = {
            self.currentPatient.street = self.viewDataDelegate!.viewContent
        }

        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=address1", completion: streetHandler)
        
        
        let cityStateZipHandler: () -> Void = {
            self.currentPatient.city = self.viewDataDelegate!.viewContent.components(separatedBy: ",")[0]
            self.currentPatient.zip = self.viewDataDelegate!.viewContent.components(separatedBy: " ").last!.replacingOccurrences(of: "--", with: "-")
        }

        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=city-state-zip", completion: cityStateZipHandler)
        
        let dobHandler: () -> Void = {
            self.currentPatient.dob = self.viewDataDelegate!.viewContent
            print("DOB Data: \(self.viewDataDelegate!.viewContent)")
        }

        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=birth-date-text", completion: dobHandler)

        let mobilePhoneHandler: () -> Void = {
            self.currentPatient.mobilePhone = self.viewDataDelegate!.viewContent
            print("Mobile Data: \(self.viewDataDelegate!.viewContent)")
        }

        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=phone-mobile", completion: mobilePhoneHandler)

        let homePhoneHandler: () -> Void = {
            self.currentPatient.homePhone = self.viewDataDelegate!.viewContent
            print("Home Data: \(self.viewDataDelegate!.viewContent)")
        }

        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=phone-home", completion: homePhoneHandler)
        
        //Get all the pieces of a patient's name
        let fullNameHandler: () -> Void = {
            let patientFullName = self.viewDataDelegate!.viewContent
            let ptNameComponents = patientFullName.nameComponentsFromFullName()
            self.currentPatient.firstName = ptNameComponents.first
            self.currentPatient.lastName = ptNameComponents.last
            self.currentPatient.middleName = ptNameComponents.middle

        }

        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=full-name", completion: fullNameHandler)

        //The insurances object is an array of tuples [(insName, insNumber)], ordered from primary to tertiary.  There are not more than three active ins at a time
        let insuranceNameHandler: () -> Void = {
            if let insuranceName = self.viewDataDelegate?.viewContent {
                print(insuranceName)
                if !insuranceName.removeWhiteSpace().isEmpty {
                    insNames.append(self.viewDataDelegate!.viewContent.replacingOccurrences(of: "|", with: ""))
                }
            }
        }
        viewDataDelegate?.getWebViewValueByQuerySelectorAll("data-element=plan-name", index: 0, completion: insuranceNameHandler)
        viewDataDelegate?.getWebViewValueByQuerySelectorAll("data-element=plan-name", index: 1, completion: insuranceNameHandler)
        viewDataDelegate?.getWebViewValueByQuerySelectorAll("data-element=plan-name", index: 2, completion: insuranceNameHandler)

        let insuranceNumberHandler: () -> Void = {
            if let insuranceNumber = self.viewDataDelegate?.viewContent {
                print(insuranceNumber)
                if !insuranceNumber.removeWhiteSpace().isEmpty {
                    insNumbers.append(self.viewDataDelegate!.viewContent.replacingOccurrences(of: "|", with: ""))
                }
            }
        }

        viewDataDelegate?.getWebViewValueByQuerySelectorAll("data-element=insured-id", index: 0, completion: insuranceNumberHandler)
        viewDataDelegate?.getWebViewValueByQuerySelectorAll("data-element=insured-id", index: 1, completion: insuranceNumberHandler)
        viewDataDelegate?.getWebViewValueByQuerySelectorAll("data-element=insured-id", index: 2, completion: insuranceNumberHandler)

        let finalHandler: () -> Void = {
            handler()
        }
        viewDataDelegate?.getWebViewValueByQuerySelector("data-element=birth-date-text", completion: finalHandler)
    }
    
    private func saveExportDialogWithData(_ data: Data, andFileName fileName: String) {
        let savePath = NSHomeDirectory()
        let saveLocation = "\(FilePath.baseFolder.rawValue)/zBertha Review/Referrals"
        
        let saveDialog = NSSavePanel()
        saveDialog.nameFieldStringValue = fileName
        saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
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
