//
//  eScriptModel.swift
//  BrowserText
//
//  Created by Fool on 4/9/20.
//  Copyright © 2020 Fool. All rights reserved.
//

import Foundation

struct eScript {
    var theText = String()
    var ptDemo: (name:String, dob:String, pharm:String, age:String) {return nameDOBPharmAge()}
    var ptName: String {return ptDemo.name}
    var ptDOB: String {return ptDemo.dob}
    var ptAge: String {return ptDemo.age}
    
    var scriptDate: String {return simpleRegExMatch(theText, theExpression: "(?m)SCRIPT DATE\\s+?.*\\s+?LAST FILL DATE").cleanTheTextOf(["SCRIPT DATE", "LAST FILL DATE"]).removeWhiteSpace()}
    var lastFillDate: String {return simpleRegExMatch(theText, theExpression: "(?m)LAST FILL DATE\\s+?.*\\s+?ASSOCIATED DIAGNOSIS").cleanTheTextOf(["LAST FILL DATE", "ASSOCIATED DIAGNOSIS"]).removeWhiteSpace()}
    var scriptMed: String {return simpleRegExMatch(theText, theExpression: "(?m)Dispensed medication\\s+?(.*\\s+?){1,2}MATCHING MEDICATION").cleanTheTextOf(["Dispensed medication", "MATCHING MEDICATION"]).removeWhiteSpace()}
    var scriptSig: String {return simpleRegExMatch(theText, theExpression: "(?m)SIG(?!\\s-)\\s+?.*\\s+?QUANTITY").cleanTheTextOf(["SIG", "QUANTITY"]).removeWhiteSpace()}
    var scriptQty: String {return simpleRegExMatch(theText, theExpression: "(?m)QUANTITY\\s+?(\\d.+?\\n+?)(?!DAYS SUPPLY).*UNIT").cleanTheTextOf(["QUANTITY","UNIT"]).removeWhiteSpace()}
    var scriptUnit: String { return simpleRegExMatch(theText, theExpression: "(?m)UNIT\\s+?.*\\s+?DAYS SUPPLY").cleanTheTextOf(["UNIT", "DAYS SUPPLY"]).removeWhiteSpace()}
    var daysSupply: String {return simpleRegExMatch(theText, theExpression: "(?m)DAYS SUPPLY\\s+?\\d.*\\s+?SUBSTITUTIONS").cleanTheTextOf(["DAYS SUPPLY", "SUBSTITUTIONS"]).removeWhiteSpace()}
    var substitutions: String {return simpleRegExMatch(theText, theExpression: "(?m)SUBSTITUTIONS\\s+?.*\\s+?NUMBER OF DISPENSINGS").cleanTheTextOf(["SUBSTITUTIONS", "NUMBER OF DISPENSINGS"]).removeWhiteSpace()}
    var dx: String {return simpleRegExMatch(theText, theExpression: "(?m)ASSOCIATED DIAGNOSIS\\s+?.*\\s+?NOTE TO PHARMACY").cleanTheTextOf(["ASSOCIATED DIAGNOSIS", "NOTE TO PHARMACY"]).removeWhiteSpace()}
    //var refills: String { return simpleRegExMatch(theText, theExpression: "(?m)NUMBER OF REFILLS\\s+?.*\\s+?SUBSTITUTIONS").cleanTheTextOf(["NUMBER OF REFILLS", "SUBSTITUTIONS"]).removeWhiteSpace()}
    var refills = ""
    
    var pharmacy: String {return ptDemo.pharm}
    
    func reportOutput() -> String {
        return """
Medication: \(scriptMed.removeWhiteSpace())
Quantity: \(scriptQty)     Units: \(scriptUnit)
Days Supply: \(daysSupply)
Substitutions: \(substitutions)

SIG: \(scriptSig)
        
Total Fills Requested: \(refills)
        
Script Date: \(scriptDate)     Last Filled: \(lastFillDate)

Associated Dx: \(dx)
"""
    }
    
    enum ScriptRegexes: String {
        case name
        case dob
        case age
        case date
        case last
        case med
        case sig
        case qty
        case pharmacy
    }
    
    //Get the name, age, and DOB from the text
    private func nameDOBPharmAge() -> (name:String, pharm:String, dob:String, age:String) {
        var ptName = ""
        var ptPharmacy = ""
        var ptDOB = ""
        var ptAge = ""
        
        let theSplitText = theText.components(separatedBy: "\n")
        
        var lineCount = 0
        if !theSplitText.isEmpty {
            for currentLine in theSplitText {
                switch true {
                case currentLine.range(of: "PRN:") != nil:
                    ptName = theSplitText[lineCount - 1]
                    lineCount += 1
//                case currentLine.range(of: "NAME") != nil && theSplitText[lineCount - 1].range(of: "Patient") != nil && ptName == "":
//                    ptName = theSplitText[lineCount + 1].replacingOccurrences(of: "Patient", with: "")
//                    lineCount += 1
                case currentLine.hasPrefix("DOB"):
                    ptDOB = theSplitText[lineCount + 1]
                    //let dobLine = theSplitText[lineCount + 1]
                    //ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
                    lineCount += 1
                case currentLine.hasPrefix("Pharmacy"):
                    let pharmacyLine = lineCount + 2
                    ptPharmacy = theSplitText[pharmacyLine]
                    lineCount += 1
                case currentLine.range(of: " yrs ") != nil:
                    ptAge = simpleRegExMatch(currentLine, theExpression: "\\d.?")
                    lineCount += 1
                default:
                    lineCount += 1
                    continue
                }
            }
            var pharmParts = ptPharmacy.components(separatedBy: " ")
            if var pharmCodeA = pharmParts.last {
                if pharmCodeA.first == "#" {
                    pharmCodeA = pharmCodeA.replacingOccurrences(of: "#", with: "")
                }
                if let pharmCodeI = Int(pharmCodeA) {
                    if let location = pharmacyCodes[pharmCodeI] {
                        pharmParts.removeLast()
                        pharmParts.insert(location, at: pharmParts.endIndex)
                        ptPharmacy = pharmParts.joined(separator: " ")
                    }
                }
            }
        }
        //print(ptName, ptPharmacy, ptDOB)
        return (ptName, ptPharmacy, ptDOB, ptAge)
        
    }
}
