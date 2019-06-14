//
//  FormLettersModel.swift
//  BrowserText
//
//  Created by Fool on 6/7/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Foundation

struct PatientDataForLetters {
    var theText:String
    
    private let currentDate = Date()
    private let formatter = DateFormatter()
    
    var labelDate:String {
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: currentDate)
    }
    
    var ptInnerName:String {return nameAgeDOB(theText).0}
    var ptLabelName:String {return getFileLabellingName(ptInnerName)}
    var ptDOB:String {return nameAgeDOB(theText).2}
    var phone:String {return nameAgeDOB(theText).3}
    
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
    
}

func createBasicLetterForPatient(_ patient:PatientDataProfile, withVerbiage verbiage:String) -> String {
    let currentDate = currentDateLong()
    let letter = """
    
    
    \(currentDate)
    
    
    
    \(patient.fullName)
    \(patient.fullAddress)
    
    
    
    
    Dear \(patient.fullName),
    
    \(verbiage)
    """
    
    return letter
}

func createNeedAptLetter(_ patient:PatientDataProfile) -> String {
    let currentDate = currentDateLong()
    let letter = """
    
    
    \(currentDate)
    
    
    
    \(patient.fullName)
    \(patient.fullAddress)
    
    
    
    
    Dear \(patient.fullName),
    
    \(needAptVerbiage)
    """
    
    return letter
}
