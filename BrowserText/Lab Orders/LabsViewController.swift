//
//  LabsViewController.swift
//  LIROS
//
//  Created by Fool on 10/30/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class LabsViewController: NSViewController {
    
    @IBOutlet var labView: NSView!
    @IBOutlet weak var labBox: NSView!
    @IBOutlet weak var fluBox: NSBox!
    
    @IBOutlet weak var reviewedCheck: NSButton!
    @IBOutlet weak var fastingCheck: NSButton!
    @IBOutlet weak var labDueMatrix: NSMatrix!
    @IBOutlet weak var addOnCheck: NSButton!
    @IBOutlet weak var other1View: NSTextField!
    @IBOutlet weak var other1DxCombo: NSComboBox!
    @IBOutlet weak var other2View: NSTextField!
    @IBOutlet weak var other2DxCombo: NSComboBox!
    
    var lastNameID = String()
    
    weak var viewDataDelegate: webViewDataProtocol?
    var theText = String()
    var currentPatient = PatientDataProfile()
    
    //Create an array of the tag number and string value for the fields in the lab box
    var labFields:[(Int, String?)] { return getTextfieldsIn(labBox)}
    
    //weak var currentPTVNDelegate: ptvnDelegate?
    //var theData = PTVN(theText: "")
    
    //let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up the choices for the dx comboboxes in the lab box
        clearLabs(self)
    }
    
    //Scrapes a view for all the textfields in a view
    //and returns an array of tuples containing the fields tag
    //and string value
    func getTextfieldsIn(_ view: NSView) -> [(Int, String?)] {
        var results = [(Int, String?)]()
        
        for item in view.subviews {
            if let isTextfield = item as? NSTextField {
                if isTextfield.isEditable {
                    results.append((isTextfield.tag, isTextfield.stringValue))
                }
            } else {
                results += getTextfieldsIn(item)
            }
        }
        return results.sorted(by: {$0.0 < $1.0})
    }
    
    //Populates the choices of the comboboxes in a view based on matching
    //the boxes tag with a switch in the LabDxValues struct
    func populateComboboxSelectionsIn(_ view: NSView, Using theStruct: populateComboBoxProtocol) {
        for item in view.subviews {
            if let isCombobox = item as? NSComboBox {
                if let dxSelections = theStruct.matchValuesFrom(isCombobox.tag) {
                    isCombobox.removeAllItems()
                    isCombobox.addItems(withObjectValues: dxSelections)
                    isCombobox.selectItem(at: 0)
                }
            } else {
                populateComboboxSelectionsIn(item, Using: theStruct)
            }
        }
        
    }
    
    @IBAction func clearLabs(_ sender: Any) {
        labView.clearControllers()
        populateComboboxSelectionsIn(labBox, Using: LabDxValues())
        //print("\n\n\n\(declinesFlu)\n\n\n")
        populateComboboxSelectionsIn(fluBox, Using: FluComboboxValues())
    }
    
    @IBAction func select90DayLabs(_ sender: Any) {
        let selection = [2, 3, 4, 17]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectDMLabs(_ sender: Any) {
        let selection = [2, 3, 4, 33, 34]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectThyLabs(_ sender: Any) {
        let selection = [4, 5 ,6]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectRheumLabs(_ sender: Any) {
        let selection = [8, 9, 10, 11, 12, 26]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectYearlyLabs(_ sender: Any) {
        let selection = [2, 3, 4, 17]
        markSelectedLabs(selection)
    }
    
    @IBAction func selectSTDLabs(_ sender: Any) {
        let selection = [14, 15, 30, 45]
        markSelectedLabs(selection)
    }
    
    
    //Marks a selection of labs in the lab box based on their tag
    //values received as the parameter.  Also sets the dx to
    //the second choice in the combo box
    func markSelectedLabs(_ tags:[Int]) {
        for item in tags {
            for box in labBox.subviews {
                if item == box.tag {
                    guard let box = box as? NSComboBox else { continue }
                    box.selectItem(at: 1)
                }
                
            }
        }
    }
    
    @IBAction func setUpLabPrinting(_sender: Any?) {
        //print("Opening Lab Printing Setup")
        //Make sure the user is on the Profile tab
        guard let profileViewData = viewDataDelegate?.viewContent else { return }
        if !profileViewData.contains("SSN") {
            //Create an alert to let the user know they aren't on the Profile tab
            //After notifying the user, break out of the program
            let theAlert = NSAlert()
            theAlert.messageText = "You need to be on the Profile tab of the patients chart in order to proceed."
            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print(returnCode)}
            //Display warning and escape
            //return
        }
        let creationHandler = {
            print(self.currentPatient.fullName)
            self.performSegue(withIdentifier: "setUpPrintLabs", sender: self)
        }
        createPatientObject(withHandler: creationHandler)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("Segueing")
        if segue.identifier! == "setUpPrintLabs" {
            if let toViewController = segue.destinationController as? LabSetUpPrintViewController {
                let processedLabs = processLabsForNote()
                if !processedLabs.isEmpty {
                    toViewController.currentPatient = currentPatient
                        toViewController.labPrintVersion = processLabsForPrint().joined(separator: "\n")
                        toViewController.labNoteVersion = "Labs ordered: \(processedLabs.joined(separator: ", "))"
                        toViewController.addOnResult = addOnCheck.state.rawValue
                    
                    
                }
            }
        }
    }
    
    func processLabsForNote() -> [String] {
        var results = Labs().processLabDataForNote(labFields)
        if let otherLabResults = processOtherLabsForNote(data: [other1View.stringValue, other2View.stringValue]) {
            if !otherLabResults.isEmpty {
            results.append(otherLabResults)
            }
        }
        
        return results
    }
    
    func processOtherLabsForNote(data:[String]) -> String? {
        var results = [String]()
        for item in data {
            if !item.isEmpty {
                results.append(item)
            }
        }
        
        return results.joined(separator: ", ")
    }
    
    func processLabsForPrint() -> [String] {
        var results = Labs().processLabDataForPrint(labFields)
        if let otherLabResults = processOtherLabsForPrint(data: [(other1View.stringValue, other1DxCombo.stringValue), (other2View.stringValue, other2DxCombo.stringValue)]) {
            results.append(otherLabResults)
        }
        return results
    }
    
    func processOtherLabsForPrint(data:[(String, String)]) -> String? {
        var results = [String]()
        for item in data {
            if !item.0.isEmpty {
                results.append("\(item.0) - \(item.1)")
            }
        }
        
        return results.joined(separator: "\n")
    }
    
    @IBAction func onlyOneCheckAtATime(_ sender:NSButton) {
        let fluCheckboxes = fluBox.getListOfButtons()
        for box in fluCheckboxes {
            if box.tag != sender.tag {
                box.state = .off
            }
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
    
//        private func createPatientObject(withHandler handler: @escaping () -> Void) {
//
//            //Get all the pieces of a patient's address
//            //Field values don't get scraped when grabbing the text/HTML on a page and have to be accessed by the .value property
//            let streetHandler: () -> Void = {
//                //print("Street Data: \(self.viewDataDelegate!.viewContent)")
//                self.currentPatient.street = self.viewDataDelegate!.viewContent
//            }
//            viewDataDelegate?.getWebViewValueByID("address-1", dataType: "value", completion: streetHandler)
//
//            let cityHandler: () -> Void = {
//                self.currentPatient.city = self.viewDataDelegate!.viewContent
//                //print("City Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("city", dataType: "value", completion: cityHandler)
//
//
//            let zipHandler: () -> Void = {
//                self.currentPatient.zip = self.viewDataDelegate!.viewContent
//                //print("Zip Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("zip-code", dataType: "value", completion: zipHandler)
//
//            let dobHandler: () -> Void = {
//                self.currentPatient.dob = self.viewDataDelegate!.viewContent
//                //print("DOB Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("birth-date", dataType: "value", completion: dobHandler)
//
//            let mobilePhoneHandler: () -> Void = {
//                self.currentPatient.mobilePhone = self.viewDataDelegate!.viewContent
//                //print("Mobile Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("mobile-phone", dataType: "value", completion: mobilePhoneHandler)
//
//            let homePhoneHandler: () -> Void = {
//                self.currentPatient.homePhone = self.viewDataDelegate!.viewContent
//                //print("Home Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("home-phone", dataType: "value", completion: homePhoneHandler)
//
//            //Get all the pieces of a patient's name
//            let firstNameHandler: () -> Void = {
//                self.currentPatient.firstName = self.viewDataDelegate!.viewContent
//                //print("First Name Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("first-name", dataType: "value", completion: firstNameHandler)
//
//            let middleNameHandler: () -> Void = {
//                self.currentPatient.middleName = self.viewDataDelegate!.viewContent
//                //print("Middle Name Data: \(self.viewDataDelegate!.viewContent)")
//            }
//            viewDataDelegate?.getWebViewValueByID("middle-name", dataType: "value", completion: middleNameHandler)
//
//            //Getting the last name first requires getting the variable ID Practice Fusion is using for this value in the HTML, then getting the value based on that ID
//            let finishThisHandler: () -> Void = {
//                let lastNameHandler: () -> Void = {
//                    self.currentPatient.lastName = self.viewDataDelegate!.viewContent
//                    //print("Last Name Data: \(self.viewDataDelegate!.viewContent)")
//                    handler()
//                }
//
//                self.viewDataDelegate?.getWebViewValueByID(self.lastNameID, dataType: "value", completion: lastNameHandler)
//            }
//
//            let lastNameIDHandler: () -> Void = {
//                self.lastNameID = getEmberIDFromScrapedString(self.viewDataDelegate!.viewContent)
//                //print("Last Name ID: \(self.viewDataDelegate!.viewContent)")
//                self.currentPatient.insurances = getInsData(self.viewDataDelegate!.viewContent)
//                finishThisHandler()
//            }
//            viewDataDelegate?.getWebViewValueByID("ember3", dataType: "innerHTML", completion: lastNameIDHandler)
//        }
	

}
