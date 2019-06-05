//
//  LabModel.swift
//  LabLetters
//
//  Created by Fool on 4/24/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

func currentDateLong() -> String {
	let formatter = DateFormatter()
	formatter.dateFormat = "MMMM d, YYYY"
	let todaysDate: String = formatter.string(from: Date())
	return todaysDate
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
