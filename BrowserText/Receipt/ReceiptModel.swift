//
//  ReceiptModel.swift
//  BrowserText
//
//  Created by Fool on 7/15/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Foundation

struct Receipt {
    var theText:String
    
    private let currentDate = Date()
    private let formatter = DateFormatter()
    var messageDate:String {
        formatter.dateFormat = "MM/dd/yyyy, h:mm a"
        return formatter.string(from: currentDate)
    }
    var labelDate:String {
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: currentDate)
    }
    
    private let timeFormatter = DateFormatter()
    var labelTime:String {
        timeFormatter.dateFormat = "HHmmss"
        return timeFormatter.string(from: currentDate)
    }
    
    var ptInnerName:String {return nameAgeDOB(theText).0}
    var ptLabelName:String {return getFileLabellingName(ptInnerName)}
//    var paymentType = String()
//    var paymentAmount = String()
//    var checkNumber = String()
//    var note = String()
//    var receiver = String()
    
    let reasonChoices = ["", "Co-pay", "Labs", "Injections", "Procedure", "Bill", "Visit"]
    let processorChoices = ["", "Nikki I.", "Bertha C.", "Tina I."]
    
    private func nameAgeDOB(_ theText: String) -> (String, String, String, String){
        var ptName = ""
        var ptAge = ""
        var ptDOB = ""
        var ptPhoneArray = [String]()
        let theSplitText = theText.components(separatedBy: "\n")
        
        var lineCount = 0
        if !theSplitText.isEmpty {
            for currentLine in theSplitText {
                if currentLine.range(of: "PRN: ") != nil {
                    let ageLine = theSplitText[lineCount + 1]
                    ptName = theSplitText[lineCount - 1].replacingOccurrences(of: "(Inactive) ", with: "")
                    ptAge = ageLine.simpleRegExMatch("^\\d*")
                } else if currentLine.hasPrefix("DOB: ") {
                    let dobLine = currentLine
                    ptDOB = dobLine.simpleRegExMatch("\\d./\\d./\\d*")
                } else if currentLine.hasPrefix("H: (") || currentLine.hasPrefix("W: (") || currentLine.hasPrefix("M: (") {
                    ptPhoneArray.append(currentLine)
                }
                lineCount += 1
            }
        }
        //print(ptName, ptAge, ptDOB, ptPhone)
        return (ptName, ptAge, ptDOB, ptPhoneArray.joined(separator: "\t"))
        
    }
    
    func getFileLabellingName(_ name: String) -> String {
        var fileLabellingName = String()
        var ptFirstName = ""
        var ptLastName = ""
        var ptMiddleName = ""
        var ptExtraName = ""
        let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
        
        func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
            var result = false
            for item in arrayToCheckIn {
                if arrayToCheckFor.contains(item) {
                    result = true
                    break
                }
            }
            return result
        }
        
        //Break the string apart into the various name bits, removing Practice Fusion's
        //'preferred' name in the process, identifying it by the parentheses
        let nameComponents = name.components(separatedBy: " ").filter {!$0.contains("(")}
        //print(nameComponents)
        
        
        let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
        
        if extraBitsCheck == true {
            ptLastName = nameComponents[nameComponents.count-2]
            ptExtraName = nameComponents[nameComponents.count-1]
        } else {
            ptLastName = nameComponents[nameComponents.count-1]
            ptExtraName = ""
        }
        
        if nameComponents.count > 2 {
            if nameComponents[nameComponents.count - 2] == "Van" {
                ptLastName = "Van " + ptLastName
            }
        }
        
        //Get first name
        ptFirstName = nameComponents[0]
        
        //Get middle name
        if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
            ptMiddleName = ""
        } else {
            ptMiddleName = nameComponents[1]
        }
        
        fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
        fileLabellingName = fileLabellingName.replacingOccurrences(of: " ", with: "")
        fileLabellingName = fileLabellingName.replacingOccurrences(of: "-", with: "")
        fileLabellingName = fileLabellingName.replacingOccurrences(of: "'", with: "")
        fileLabellingName = fileLabellingName.replacingOccurrences(of: "(", with: "")
        fileLabellingName = fileLabellingName.replacingOccurrences(of: ")", with: "")
        fileLabellingName = fileLabellingName.replacingOccurrences(of: "\"", with: "")
        
        
        return fileLabellingName
    }
    
    
    enum PaymentType:String {
        case copay = "Copay"
        case officeVisit = "Office Visit"
        case balance = "Balance"
        case labs = "Labs"
        case injection = "Injection"
        case records = "Medical Records"
    }
    
    enum PaymentMethod:String {
        case cash = "Cash"
        case check = "Check"
        case credicCard = "Credit Card"
        case moneyOrder = "Money Order"
    }
    
    enum Receiver:String {
        case nikki = "Nikki Irving"
        case bertha = "Bertha Cowart"
        case tina = "Tina Irving"
    }
}
