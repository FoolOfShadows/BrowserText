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
        }
    }
    
    @IBAction func printNoShowLetter(_ sender: Any?) {
        let creationHandler = {
            printLetterheadWithText(createNoShowLetter(self.currentPatient), fontSize: 14.0)
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
        let streetHandler: () -> Void = {
            self.currentPatient.street = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByID("address-1", dataType: "value", completion: streetHandler)
        
        let cityHandler: () -> Void = {
            self.currentPatient.city = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByID("city", dataType: "value", completion: cityHandler)
        
//        let stateHandler: () -> Void = {
//            self.currentPatient.state = self.viewDataDelegate!.viewContent
//        }
//        viewDataDelegate?.getWebViewValueByID("ember61922", dataType: "value", completion: stateHandler)
        
        let zipHandler: () -> Void = {
            self.currentPatient.zip = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByID("zip-code", dataType: "value", completion: zipHandler)
        
        //Get all the pieces of a patient's name
        let firstNameHandler: () -> Void = {
            self.currentPatient.firstName = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByID("first-name", dataType: "value", completion: firstNameHandler)
        
        let middleNameHandler: () -> Void = {
            self.currentPatient.middleName = self.viewDataDelegate!.viewContent
        }
        viewDataDelegate?.getWebViewValueByID("middle-name", dataType: "value", completion: middleNameHandler)
        
        //Getting the last name first requires getting the variable ID Practice Fusion is using for this value in the HTML, then getting the value based on that ID
        let finishThisHandler: () -> Void = {
            let lastNameHandler: () -> Void = {
                self.currentPatient.lastName = self.viewDataDelegate!.viewContent
                handler()
            }
            
            self.viewDataDelegate?.getWebViewValueByID(self.lastNameID, dataType: "value", completion: lastNameHandler)
        }
        
        let lastNameIDHandler: () -> Void = {
            self.lastNameID = getEmberIDFromScrapedString(self.viewDataDelegate!.viewContent)
            finishThisHandler()
        }
        viewDataDelegate?.getWebViewValueByID("ember311", dataType: "innerHTML", completion: lastNameIDHandler)
    }
}
