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

enum ReferralSectionDelimiters:String {
    //    case ptNameFirstStart = "#NAMEFIRST"
    //    case ptNameFirstEnd = "NAMEFIRST#"
    //
    //    case ptNameLastStart = "#NAMELAST"
    //    case ptNameLastEnd = "NAMELAST#"
    //
    //    case ptNameMiddleStart = "#NAMEMIDDLE"
    //    case ptNameMiddleEnd = "NAMEMIDDLE#"
    
    case ptNameStart = "#PATIENTNAME"
    case ptNameEnd = "PATIENTNAME#"
    
    case ptDOBStart = "#DOB"
    case ptDOBEnd = "DOB#"
    
    case ptAgeStart = "#AGE"
    case ptAgeEnd = "AGE#"
    
    case ptMobileStart = "#MOBILEPHONE"
    case ptMobileEnd = "MOBILEPHONE#"
    
    case ptHomeStart = "#HOMEPHONE"
    case ptHomeEnd = "HOMEPHONE#"
    
    case ptAddressStart = "#PATIENTADDRESS"
    case ptAddressEnd = "PATIENTADDRESS#"
    
    case activityTypeStart = "#ACTIVITYTYPE"
    case activityTypeEnd = "ACTIVITYTYPE#"
    
    case paNeededStart = "#PANEEDED"
    case paNeededEnd = "PANEEDED#"
    
    case insuranceStart = "#ALLINSURANCE"
    case insuranceEnd = "ALLINSURANCE#"
    
    case specNameStart = "#SPECNAME"
    case specNameEnd = "SPECNAME#"
    
    case specAddressStart = "#SPECADDRESS"
    case specAddressEnd = "SPECADDRESS#"
    
    case specPhoneStart = "#SPECPHONE"
    case specPhoneEnd = "SPECPHONE#"
    
    case specFaxStart = "#SPECFAX"
    case specFaxEnd = "SPECFAX#"
    
    case specialtyStart = "#SPECIALTY"
    case specialtyEnd = "SPECIALTY#"
    
    case specNPIStart = "#NPI"
    case specNPIEnd = "NPI#"
    
    case specContactStart = "#CONTACT"
    case specContactEnd = "CONTACT#"
    
    case testLocationStart = "#LOCATION"
    case testLocationEnd = "LOCATION#"
    
    case testTimeStart = "#TIME"
    case testTimeEnd = "TIME#"
    
    case testTypeStart = "#TESTTYPE"
    case testTypeEnd = "TESTTYPE#"
    
    case paInsNameStart = "#PAINSNAME"
    case paInsNameEnd = "PAINSNAME#"
    
    case paInsPhoneStart = "#PAINSPHONE"
    case paInsPhoneEnd = "PAINSPHONE#"
    
    case paInsFaxStart = "#PAINSFAX"
    case paInsFaxEnd = "PAINSFAX#"
    
    case infoNeededStart = "#INFONEEDED"
    case infoNeededEnd = "INFONEEDED#"
    
    case infoSentStart = "#INFOSENT"
    case infoSentEnd = "INFOSENT#"
    
    case paDeclinedStart = "#PADECLINED"
    case paDeclinedEnd = "PADECLINED#"
    
    case ptNotifiedStart = "#NOTIFIED"
    case ptNotifiedEnd = "NOTIFIED#"
    
    case notesStart = "#NOTES"
    case notesEnd = "NOTES#"
}

func createReferral(_ patient:PatientDataProfile) -> String {
    let currentDate = currentDateLong()
    let nonPrimeIns = patient.insurances.dropFirst()
    
//    let letter = """
//
//
//    \(currentDate)
//
//    \(patient.fullName)          DOB: \(patient.dob) (\(patient.age))
//    \(patient.fullAddress)
//
//    Home Phone: \(patient.homePhone)
//    Mobile Phone: \(patient.mobilePhone)
//
//    Primary Ins: \(patient.insurances[0].0) - \(patient.insurances[0].1)
//    Other Ins: \(nonPrimeIns.map { "\($0.0) - \($0.1)"}.joined(separator: "\n\t"))
//
//
//
//    Dr/Clinic Name:
//
//    Specialty:                                     NPI:
//    Address:
//
//    Phone:                                    Fax:
//
//
//    Test Ordered:
//
//    DX:
//
//    INFO NEEDED
//    Demo    ML    Dx    Rad    Labs    Ins    ONs
//
//
//    PA Needed:  Y    N
//    Ins Name: \(patient.insurances[0].0)
//    Phone:                      Fax:
//
//
//
//    Declined:
//
//    Pt Notified:
//    """
    
    let formattedInsurance = patient.insurances.map { "\($0.0) - \($0.1)"}.joined(separator: "\n")
    let letter = """
    #REFERRALFILE#
    
    \(ReferralSectionDelimiters.ptNameStart.rawValue)
    \(patient.fullName)
    \(ReferralSectionDelimiters.ptNameEnd.rawValue)
    
    \(ReferralSectionDelimiters.ptDOBStart.rawValue)
    \(patient.dob)
    \(ReferralSectionDelimiters.ptDOBEnd.rawValue)
    
    \(ReferralSectionDelimiters.ptAgeStart.rawValue)
    \(patient.age)
    \(ReferralSectionDelimiters.ptAgeEnd.rawValue)
    
    \(ReferralSectionDelimiters.ptMobileStart.rawValue)
    \(patient.mobilePhone)
    \(ReferralSectionDelimiters.ptMobileEnd.rawValue)
    
    \(ReferralSectionDelimiters.ptHomeStart.rawValue)
    \(patient.homePhone)
    \(ReferralSectionDelimiters.ptHomeEnd.rawValue)
    
    \(ReferralSectionDelimiters.ptAddressStart.rawValue)
    \(patient.fullAddress)
    \(ReferralSectionDelimiters.ptAddressEnd.rawValue)
    
    \(ReferralSectionDelimiters.activityTypeStart.rawValue)
    \(ReferralSectionDelimiters.activityTypeEnd.rawValue)
    
    \(ReferralSectionDelimiters.paNeededStart.rawValue)
    \(ReferralSectionDelimiters.paNeededEnd.rawValue)
    
    \(ReferralSectionDelimiters.insuranceStart.rawValue)
    \(formattedInsurance)
    \(ReferralSectionDelimiters.insuranceEnd.rawValue)
    
    \(ReferralSectionDelimiters.specNameStart.rawValue)
    \(ReferralSectionDelimiters.specNameEnd.rawValue)
    
    \(ReferralSectionDelimiters.specAddressStart.rawValue)
    \(ReferralSectionDelimiters.specAddressEnd.rawValue)
    
    \(ReferralSectionDelimiters.specPhoneStart.rawValue)
    \(ReferralSectionDelimiters.specPhoneEnd.rawValue)
    
    \(ReferralSectionDelimiters.specFaxStart.rawValue)
    \(ReferralSectionDelimiters.specFaxEnd.rawValue)
    
    \(ReferralSectionDelimiters.specialtyStart.rawValue)
    \(ReferralSectionDelimiters.specialtyEnd.rawValue)
    
    \(ReferralSectionDelimiters.specNPIStart.rawValue)
    \(ReferralSectionDelimiters.specNPIEnd.rawValue)
    
    \(ReferralSectionDelimiters.specContactStart.rawValue)
    \(ReferralSectionDelimiters.specContactEnd.rawValue)
    
    \(ReferralSectionDelimiters.testLocationStart.rawValue)
    \(ReferralSectionDelimiters.testLocationEnd.rawValue)
    
    \(ReferralSectionDelimiters.testTimeStart.rawValue)
    \(ReferralSectionDelimiters.testTimeEnd.rawValue)
    
    \(ReferralSectionDelimiters.testTypeStart.rawValue)
    \(ReferralSectionDelimiters.testTypeEnd.rawValue)
    
    \(ReferralSectionDelimiters.paInsNameStart.rawValue)
    \(ReferralSectionDelimiters.paInsNameEnd.rawValue)
    
    \(ReferralSectionDelimiters.paInsPhoneStart.rawValue)
    \(ReferralSectionDelimiters.paInsPhoneEnd.rawValue)
    
    \(ReferralSectionDelimiters.paInsFaxStart.rawValue)
    \(ReferralSectionDelimiters.paInsFaxEnd.rawValue)
    
    \(ReferralSectionDelimiters.infoNeededStart.rawValue)
    \(ReferralSectionDelimiters.infoNeededEnd.rawValue)
    
    \(ReferralSectionDelimiters.infoSentStart.rawValue)
    \(ReferralSectionDelimiters.infoSentEnd.rawValue)
    
    \(ReferralSectionDelimiters.paDeclinedStart.rawValue)
    \(ReferralSectionDelimiters.paDeclinedEnd.rawValue)
    
    \(ReferralSectionDelimiters.ptNotifiedStart.rawValue)
    \(ReferralSectionDelimiters.ptNotifiedEnd.rawValue)
    
    \(ReferralSectionDelimiters.notesStart.rawValue)
    \(ReferralSectionDelimiters.notesEnd.rawValue)
    """
    
    return letter
}
