//
//  RegularExpressions.swift
//  BrowserText
//
//  Created by Fool on 2/28/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Foundation

enum RegularExpressions:String {
    case ptName = "(?s)\"patient-name\">.*?</span>"
    case ptAgeGender = "(?s)>\\d* yrs [A-Z]</div>"
    case ptDOB = "(?s)\"patient-ribbon-dob\">\\d\\d/\\d\\d/\\d\\d\\d\\d</span>"
    case ptDx = "(?s)\"diagnosis-item-text\" class=\"text-color-link text-wrap\">.*?<!"
    case psh = "(?s)Major events.*?</a>"
    case pmh = "(?s)Ongoing medical problems.*?</a>"
    //case allergies = ""
    //case fx = ""
    //case sx = ""
    //case nx = ""
    case medications = "(?s)\"medication-name\">.*?(datetime|</li>)"
}

let extraPtNameBits = ["\"patient-name\">", "</span>"]
let extraPtAgeGenderBits = ["</div>", ">"]
let extraPtDOBBits = ["\"patient-ribbon-dob\">", "</span>"]
let extraPtDxBits = ["\"diagnosis-item-text\" class=\"text-color-link text-wrap\">", "<!"]
let extraPSHBits = [/*"Major events", "PSH:",*/ "</a>"]
let extraPMHBits = [/*"Ongoing medical problems", "PMH:",*/"</a>"]


func cleanPMH(_ text:String) -> [String] {
    var cleanedText = text.replacingOccurrences(of: text.simpleRegExMatch("(?s)Ongoing medical problems.*?<br>-"), with: "")
    cleanedText = cleanedText.replacingOccurrences(of: text.simpleRegExMatch("(?s)Major events.*?<br>-"), with: "")
    let pshArray = cleanedText.components(separatedBy: "<br>-  ")
    return pshArray
}
