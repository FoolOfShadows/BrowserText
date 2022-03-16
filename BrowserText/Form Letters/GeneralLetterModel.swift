//
//  GeneralLetterModel.swift
//  BrowserText
//
//  Created by FoolOfShadows on 4/1/21.
//  Copyright © 2021 Fool. All rights reserved.
//

import Foundation
import Cocoa

struct GeneralLetterData {
    var ltrDate:String
    var ptName:String
    var address:String
    var ltrBody:String
    var senderName: String
    var senderTitle: String
    
    
    func generateOutput() -> NSAttributedString {
        //Set up a dictionary of font attributes for setting the final string to
        let font = NSFont(name: "Times New Roman", size: 14)
        let stringAttributes: [NSAttributedString.Key: Any] = [
            .font:font!
        ]
        
        //Instatiate the foundational string to be built upon
        let baseString = NSMutableAttributedString()
        
        let header = NSAttributedString(string: "\(ltrDate)\n\n\(ptName)\n\(address)\n\n\nDear \(ptName),\n\n")
        
        baseString.append(header)
        
        let letterBody = NSAttributedString(string: "\(ltrBody)\n\n\n\n")
        baseString.append(letterBody)
        let signature = NSAttributedString(string: "\(senderName)\n\(senderTitle)")
        baseString.append(signature)
        
        baseString.addAttributes(stringAttributes, range: NSRange(location: 0, length: baseString.string.count))
        
        return baseString
    }
}
