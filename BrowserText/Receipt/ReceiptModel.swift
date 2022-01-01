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
    
    var ptDemo:PatientDemo {return PatientDemo(theText: theText)}
    
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
    
    var ptInnerName:String {return ptDemo.ptName}
    var ptLabelName:String {return getFileLabellingName(ptInnerName)}
    
    let reasonChoices = ["", "Co-pay", "Labs", "Injections", "Procedure", "Bill", "Visit"]
    let processorChoices = ["", "Rachel D.", "Bertha C.", "Tina I."]
    
    
    private func getFileLabellingName(_ name: String) -> String {
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
        case rachel = "Rachel Davis"
        case bertha = "Bertha Cowart"
        case tina = "Tina Irving"
    }
}
