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
                self.currentPatient.street = self.viewDataDelegate!.viewContent
            }

            viewDataDelegate?.getWebViewValueByQuerySelector("data-element=address1", completion: streetHandler)
            
            let cityStateZipHandler: () -> Void = {
                self.currentPatient.city = self.viewDataDelegate!.viewContent.components(separatedBy: ",")[0]
                self.currentPatient.zip = self.viewDataDelegate!.viewContent.components(separatedBy: " ").last!
            }

            viewDataDelegate?.getWebViewValueByQuerySelector("data-element=city-state-zip", completion: cityStateZipHandler)
            
            let dobHandler: () -> Void = {
                self.currentPatient.dob = self.viewDataDelegate!.viewContent
            }

            viewDataDelegate?.getWebViewValueByQuerySelector("data-element=birth-date-text", completion: dobHandler)
            
            let mobilePhoneHandler: () -> Void = {
                self.currentPatient.mobilePhone = self.viewDataDelegate!.viewContent
            }

            viewDataDelegate?.getWebViewValueByQuerySelector("data-element=phone-mobile", completion: mobilePhoneHandler)
            
            let homePhoneHandler: () -> Void = {
                self.currentPatient.homePhone = self.viewDataDelegate!.viewContent
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

            viewDataDelegate?.getWebViewValueByQuerySelector("data-element=birth-date-text", completion: finalHandler)
        }
}
