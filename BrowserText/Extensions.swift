//
//  Extensions.swift
//  BrowserText
//
//  Created by Fool on 2/28/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

//MARK: String Extensions
extension String {
    
    func simpleRegExMatch(_ theExpression: String) -> String {
        var theResult = ""
        let regEx = try! NSRegularExpression(pattern: theExpression, options: [.anchorsMatchLines])
        let length = self.count
        
        if let match = regEx.firstMatch(in: self, options: [], range: NSRange(location: 0, length: length)) {
            theResult = (self as NSString).substring(with: match.range)
        }
        return theResult
    }
    
    func findRegexMatchesOf(_ expression:String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: expression) else { return [""]}
        let theString = self as NSString
        return regex.matches(in: self, options: [], range: NSRange(location: 0, length: theString.length)).map { theString.substring(with: $0.range) }
    }
    
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func cleanTheTextOf(_ badBits:[String]) -> String {
        var cleanedText = self.removeWhiteSpace()
        for theBit in badBits {
            //cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
            cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "", options: .regularExpression, range: nil)
        }
        let cleanedArray = cleanedText.components(separatedBy: "\n").filter {!$0.allRegexMatchesFor("[a-zA-Z0-9]").isEmpty}
        //let cleanedArray = cleanedText.components(separatedBy: "\n").filter {!$0.ranges(of: "[a-zA-Z0-9]", options: .regularExpression).isEmpty}
        cleanedText = cleanedArray.joined(separator: "\n").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return cleanedText
    }
    
    //This method returns an array of all substrings in a string which match the regex passed in
    func allRegexMatchesFor(_ regex: String) -> [String] {
        //If the string passed in can't be converted to a regex, return an empty array
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        //Get an array textcheckingresults (ranges) of matches for the regex in the
        //calling string
        let results = regex.matches(in: self,
                                    range: NSRange(self.startIndex..., in: self))
        //Convert the textcheckingresults into an array of strings using map()
        //and return the results
        return results.map { (self as NSString).substring(with: $0.range) }
    }
    
    func replaceRegexPattern(_ pattern:String, with goodBit:String) -> String {
        let regex = try? NSRegularExpression(pattern: pattern)
        if let results = regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0,length: self.count), withTemplate: goodBit) {
            return results
        }
        
        return ""
    }
    
    func convertListToArray() -> [String] {
        let baseArray = self.components(separatedBy: "\n")
        //let newArray = baseArray.map { $0.cleanTheTextOf(["-  "]) }
        return baseArray
    }
    
    func findRegexMatchFrom(_ start: String, to end:String) -> String? {
        if self.contains(start) && self.contains(end) {
            guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
            guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
            let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            
            let startRange = startMatch[0].range
            let endRange = endMatch[0].range
            
            let r = self.index(self.startIndex, offsetBy: startRange.location) ..< self.index(self.startIndex, offsetBy: endRange.location + endRange.length)
            
            return String(self[r])
        } else {
            return ""
        }
    }
    
    func findRegexMatchBetween(_ start: String, and end: String) -> String? {
        let startStripped = start.removeRegexCharactersFromString()
        let endStripped = end.removeRegexCharactersFromString()
        //print("Stripped start is: \(startStripped)\nand stripped end is: \(endStripped)")
        if self.contains(startStripped) && self.contains(endStripped) {
            //print("Starting text: \(start), Ending text: \(end)")
            guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
            guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
            
            let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            
            let startRange = startMatch[0].range
            let endRange = endMatch[0].range
            
            //print("Start range is \(startRange.location), and the end range is \(endRange.location)")
            
            if startRange.location > endRange.location {
                return "Range for this section is out of bounds"
            } else {
                let r = self.index(self.startIndex, offsetBy: startRange.location + startRange.length) ..< self.index(self.startIndex, offsetBy: endRange.location)
                
                return String(self[r])
            }
        } else {
            return ""
        }
    }
    
    func removeRegexCharactersFromString() -> String {
        let regexCharacters:Set<Character> = Set("\\*")
        return String(self.filter({ !regexCharacters.contains($0) }))
    }
    
    func addCharacterToBeginningOfEachLine(_ theCharacter:String) -> String {
        var newTextArray = [String]()
        let textArray = self.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty}
        for line in textArray {
            newTextArray.append("\(theCharacter) \(line)")
        }
        
        return newTextArray.joined(separator: "\n")
    }
    
    //A cribbed extension allowing for the extraction of blocks of text.  I don't yet understand how it works.
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    
    func copyToPasteboard() {
        let myPasteboard = NSPasteboard.general
        myPasteboard.clearContents()
        myPasteboard.setString(self, forType: NSPasteboard.PasteboardType.string)
    }
}

extension Date {
    func addingDays(_ daysToAdd: Int) -> Date? {
        var components = DateComponents()
        components.setValue(daysToAdd, for: .day)
        let newDate = Calendar.current.date(byAdding: components, to: self)
        return newDate
    }
    
    func shortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        return formatter.string(from: self)
    }
}

extension NSView {
    func clearControllers() {
        func clearChecksTextfields(theView: NSView) {
            for item in theView.subviews {
                if item is NSButton {
                    let checkbox = item as? NSButton
                    if (checkbox?.isEnabled)! {
                        checkbox?.state = .off
                    }
                } else if item is NSTextField {
                    let textfield = item as? NSTextField
                    if (textfield?.isEditable)!{
                        textfield?.stringValue = ""
                    }
                } else if item is NSMatrix {
                    let matrix = item as? NSMatrix
                    matrix?.deselectAllCells()
                } else if item is NSTextView {
                    let textView = item as? NSTextView
                    if (textView?.isEditable)! {
                        textView?.string = ""
                    }
                } else {
                    clearChecksTextfields(theView: item)
                }
            }
        }
        clearChecksTextfields(theView: self)
    }
}

extension NSComboBox {
    func clearComboBox(menuItems: [String]) {
        self.removeAllItems()
        self.addItems(withObjectValues: menuItems)
        self.selectItem(at: 0)
        self.completes = true
    }
}
