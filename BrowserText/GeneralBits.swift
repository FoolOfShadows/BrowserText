//
//  LabModel.swift
//  LabLetters
//
//  Created by Fool on 4/24/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

enum FilePath:String {
    case baseFolder = "WPCM Dropbox/WPCMSharedFiles"
    case ptvnStorage = "zDonna Review/01 PTVN Files"
    case todayPTVNs = "zDoctor Review/06 Dummy Files"
    case tomorrowPTVNs = "zruss Review/Tomorrows Files"
    case receipts = "zDonna Review/02 RECEIPTS"
    case scrapedScripts = "Scraped Data/Scripts"
    case scrapedRefs = "Scraped Data/Referrals"
    case scrapedPHM = "Scraped Data/PMH Updates"
    case dawnSigFile = "WPCM Software Bits/00 CAUTION - Data Files/DawnSig1.png"
    case textCleaningFile = "WPCM Software Bits/00 CAUTION - Data Files/PTVN2PFCleaningDataBasic.txt"
}

func currentDateLong() -> String {
	let formatter = DateFormatter()
	formatter.dateFormat = "MMMM d, yyyy"
	return formatter.string(from: Date())
}


extension NSView {
	//If the text of an NSTextField in a view matches certain criteria its color will be set to red
	func highlightOutOfRangeResults() {
		func highlightResults(theView: NSView) {
			for item in theView.subviews {
				switch item {
				case is NSTextField:
					let textField = item as? NSTextField
					if (textField?.isEditable)! {
						if (textField?.stringValue.contains("High"))! || (textField?.stringValue.contains("Low"))! || (textField?.stringValue.contains("POSITIVE"))! || (textField?.stringValue.contains("Overactive"))! || (textField?.stringValue.contains("Underactive"))! {
							//Swift.print("Things should be turning red")
							textField?.textColor = NSColor.red
						}
					}
				case is NSView:
					highlightResults(theView: item)
				default: continue
				}
			}
		}
		highlightResults(theView: self)
	}
}

extension String {

	func prependSectionHeader(_ header:String) -> String {
		if !self.isEmpty {
			return "\(header.uppercased())\n\(self)"
		}
		return self
	}
	
	func prependLineHeader(_ header:String) -> String {
		if !self.isEmpty {
			return "\(header):  \(self)"
		}
		return self
	}
	

}

func getDateRegEx(_ dateLine: String) -> String {
	var theMatch = ""
    let lineCount = dateLine.count
	//let lineCount = dateLine.characters.count
	let textAsNSString = dateLine as NSString
	let theRegEx = try! NSRegularExpression(pattern: "\\d./\\d./\\d*", options: [])
	for match in theRegEx.matches(in: dateLine, options: [], range: NSMakeRange(0, lineCount)) as [NSTextCheckingResult] {
		for item in 0..<match.numberOfRanges {
			theMatch = textAsNSString.substring(with: match.range)
			//theMatch = textAsNSString.substring(with: match.range(at: item))
			let startDigit = theMatch.first
			if startDigit == "0" {
				theMatch = String(theMatch.dropFirst())
			}
		}
	}
	
	return theMatch
}

func getAgeFrom(DOB:String) -> String {
    let dobComponents = DOB.components(separatedBy: "/")
    guard let month = Int(dobComponents[0]) else { return "Unable to calculate age"}
    guard let day = Int(dobComponents[1]) else { return "Unable to calculate age"}
    guard let year = Int(dobComponents[2]) else { return "Unable to calculate age"}
    
    let birthdate = DateComponents(year: year, month: month, day: day)
    //Calculate age
    let calendar = Calendar.current
    let now = calendar.dateComponents([.year, .month, .day], from: Date())
    let ageComponents = calendar.dateComponents([.year], from: birthdate, to: now)
    return String(ageComponents.year!)
}


func createFileLabelFrom(PatientName name:String, FileType type:String, date:String) -> String {
    //Format Date
    var dateComponents = date.split(separator: "/")//extractedLabData.labDateString?.split(separator: "/") ?? [""]
    if dateComponents.count == 3 {
        dateComponents = [dateComponents[2], dateComponents[0], dateComponents[1]]
    }
    var paddedComponents = [String]()
    for item in dateComponents {
        if item.count < 2 {
            paddedComponents.append("0\(item)")
        } else {
            paddedComponents.append(String(item))
        }
    }
    var finalComponents = [String]()
    for item in paddedComponents {
        if item.count == 4 {
            finalComponents.append(String(item.suffix(2)))
        } else {
            finalComponents.append(item)
        }
    }
    
    let results = [name, type, finalComponents.joined(separator: "")]
    
    return results.joined(separator: " ")
}
