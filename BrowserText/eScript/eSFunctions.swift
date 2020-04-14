//
//  Functions.swift
//  Chart Parsing
//
//  Created by Fool on 6/17/15.
//  Copyright (c) 2015 Fulgent Wake. All rights reserved.
//

import Cocoa
import Foundation

func getLastAptInfoFrom(_ theText: String) -> String {
    let baseSection = theText.findRegexMatchFrom("Encounters", to: "Appointments")
    //print(baseSection)
    let encountersSection = baseSection.findRegexMatchBetween("Encounters", and: "Messages")
    //print(encountersSection)
    let activeEncounters = encountersSection.ranges(of: "(?s)(\\d./\\d./\\d*)(.*?)(\\n)(?=\\d./\\d./\\d*)", options: .regularExpression).map{encountersSection[$0]}.map{String($0)}.filter {!$0.contains("No chief complaint recorded")}
    //print(activeEncounters)
    if activeEncounters.count > 0 {
        return activeEncounters[0].simpleRegExMatch("\\d./\\d./\\d*")
    } else {
        return "Last apt not found"
    }
}





    
//Get the name, age, and DOB from the text
func nameAgeDOB(_ theText: String?) -> (String, String, String)? {
	var ptName = ""
	var ptPharmacy = ""
	var ptDOB = ""
	guard let theSplitText = theText?.components(separatedBy: "\n") else { return nil }
	
	var lineCount = 0
	if !theSplitText.isEmpty {
		for currentLine in theSplitText {
			switch true {
			case currentLine.range(of: "PRN:") != nil:
				ptName = theSplitText[lineCount - 1]
				lineCount += 1
            case currentLine.range(of: "NAME") != nil && theSplitText[lineCount - 1].range(of: "Patient") != nil && ptName == "":
				ptName = theSplitText[lineCount + 1].replacingOccurrences(of: "Patient", with: "")
				lineCount += 1
			case currentLine.hasPrefix("DOB"):
				let dobLine = theSplitText[lineCount + 1]
				ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
				lineCount += 1
			case currentLine.hasPrefix("Pharmacy"):
				let pharmacyLine = lineCount + 2
				ptPharmacy = theSplitText[pharmacyLine]
				lineCount += 1
			default:
				lineCount += 1
				continue
			}
//			if currentLine.range(of: "PRN: ") != nil {
//				ptName = theSplitText[lineCount - 1]
//				print(lineCount)
//				continue
//			} else if currentLine.range(of: "Gender") != nil {
//				ptName = theSplitText[lineCount - 2].replacingOccurrences(of: "Patient", with: "")
//			} else if currentLine.hasPrefix("DOB"){
//				let dobLine = currentLine
//				ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
//			} else if currentLine.hasPrefix("Pharmacy") {
//				let pharmacyLine = lineCount + 1
//				ptPharmacy = theSplitText[pharmacyLine]
//			}
//			lineCount += 1
		}
	}
    print(ptName, ptPharmacy, ptDOB)
	return (ptName, ptPharmacy, ptDOB)
	
}

//Check for the existence of certain strings in the text
//in order to determine the best string to use in the regexTheText function
func defineFinalParameter(_ theText: String, firstParameter: String, secondParameter: String) -> String {
	var theParameter = ""
	if theText.range(of: firstParameter) != nil {
		theParameter = firstParameter
	} else if theText.range(of: secondParameter) != nil {
		theParameter = secondParameter
	}
	return theParameter
}

	


//A basic regular expression search function
func simpleRegExMatch(_ theText: String, theExpression: String) -> String {
	var theResult = ""
	let regEx = try! NSRegularExpression(pattern: theExpression, options: [])
	let length = theText.count
	
	if let match = regEx.firstMatch(in: theText, options: [], range: NSRange(location: 0, length: length)) {
		theResult = (theText as NSString).substring(with: match.range)
	}
	return theResult
}

func replaceLabelsOf(_ array: inout [String], with subs:[(String, String)]) -> [String] {
	var results = array
	for (position, item) in results.enumerated() {
		for sub in subs {
			if item.contains(sub.0) {
				//print(item, sub.0)
				results.remove(at: position)
				let newItem = item.replacingOccurrences(of: sub.0, with: sub.1)
				results.insert(newItem, at: position)
			}
		}
	}
	return results
}


func getScriptDataFrom(_ text:String?) -> String {
	var finalScriptData = "Program failed to find script data."
	if let scriptData = text?.simpleRegExMatch("(?s)Prescribed.*?ASSOCIATED DIAGNOSIS")/*text?.findRegexMatchFrom("Prescribed", to: "ASSOCIATED DIAGNOSIS")*/ {
    //if let scriptData = text?.simpleRegExMatch("(?s)Dispensed medication.*?ASSOCIATED DIAGNOSIS") {
        //print("Script Data: \(scriptData)")
//        let extraneousData = scriptData.simpleRegExMatch("(?s)MATCHING MEDICATION.*Select override reason")
//        print(extraneousData)
//        var dataArray:[String] = scriptData.replacingOccurrences(of: extraneousData, with: "").components(separatedBy: "\n")
		var dataArray:[String] = scriptData.components(separatedBy: "\n")
		dataArray = dataArray.filter {!$0.isEmpty}
		//print(dataArray)
		let changedData = replaceLabelsOf(&dataArray, with: replacementSet)
		//print(changedData)
		
		finalScriptData = changedData.joined(separator: "\n")
	}
		
		return finalScriptData
}

func checkPharmacyLocationFrom(_ pharm:String) -> String {
	var result = pharm
	var pharmParts = pharm.components(separatedBy: " ")
	//print(pharmParts)
	guard var pharmCode = pharmParts.last else { return result }
	if pharmCode.first == "#" {
		//print("Replacing")
		pharmCode = pharmCode.replacingOccurrences(of: "#", with: "")
	}
	if let pharmCode = Int(pharmCode) {
		//print(pharmCode)
		if let location = pharmacyCodes[pharmCode] {
			pharmParts.removeLast()
			pharmParts.insert(location, at: pharmParts.endIndex)
			result = pharmParts.joined(separator: " ")
		}
	}
	
	return result
}



