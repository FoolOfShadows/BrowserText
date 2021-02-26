//
//  Patient Demo.swift
//  BrowserText
//
//  Created by FoolOfShadows on 2/26/21.
//  Copyright © 2021 Fool. All rights reserved.
//

import Foundation

struct PatientDemo {
    //var theText:String
    var ptName = ""
    var ptAge = ""
    var ptDOB = ""
    var ptPhoneArray = [String]()
    
    init (theText:String) {
        let theSplitText = theText.components(separatedBy: "\n")
        
        var lineCount = 0
        if !theSplitText.isEmpty {
            for currentLine in theSplitText {
                if currentLine.range(of: "PRN: ") != nil {
                    let ageLine = theSplitText[lineCount + 2]
                    self.ptName = theSplitText[lineCount - 1].replacingOccurrences(of: "(Inactive) ", with: "")
                    self.ptAge = ageLine.simpleRegExMatch("^\\d*")
                } else if currentLine.hasPrefix("DOB: ") {
                    let dobLine = /*currentLine*/ theSplitText[lineCount + 1]
                    self.ptDOB = dobLine.simpleRegExMatch("\\d./\\d./\\d*")
                } else if currentLine.hasPrefix("H: ") || currentLine.hasPrefix("W: ") || currentLine.hasPrefix("M: ") {
                    let phoneLine = theSplitText[lineCount + 1]
                    self.ptPhoneArray.append("\(currentLine)\(phoneLine)")
                }
                lineCount += 1
            }
        }
    }
}
