//
//  ChartData.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Foundation

//Struct to hold the data from the file
class ChartData {
    //This string will be populated later with data on the clipboard pulled from PF
    var chartData:String
    
    
    //Use closures to populate the relevant vars with the desired data copied from PF
    var ptName: String {return nameAgeDOB(chartData).0}
    var ptDOB: String {return nameAgeDOB(chartData).2}
    var ptAge: String {return nameAgeDOB(chartData).1}
    var currentMeds: String {return chartData.simpleRegExMatch(Regexes.medications.rawValue).cleanTheTextOf(medBadBits).addCharacterToBeginningOfEachLine("-")}
    var diagnoses: String {return chartData.simpleRegExMatch(Regexes.diagnoses.rawValue).cleanTheTextOf(dxBadBits)}
    var allergies: String {return chartData.simpleRegExMatch(Regexes.allergies.rawValue).cleanTheTextOf(basicAllergyBadBits)}
    var nutritionalHistory: String { var theRegex = ""
                                    if chartData.contains("Developmental history") {
                                    theRegex = Regexes.nutrition1.rawValue
                                        //print("Found Dev Hx")
                                    } else { theRegex = Regexes.nutrition2.rawValue}
                                    return chartData.simpleRegExMatch(theRegex).cleanTheTextOf(nutritionBadBits)}
    var socialHistory: String {return chartData.simpleRegExMatch(Regexes.social.rawValue).cleanTheTextOf(socialBadBits)}
    var familyHistory: String {return chartData.simpleRegExMatch(Regexes.family1.rawValue).cleanTheTextOf(fmhBadBits)}
    var preventiveCare: String {return chartData.simpleRegExMatch(Regexes.preventive.rawValue).cleanTheTextOf(preventiveBadBits)}
     var preventiveCare2: String { return chartData.simpleRegExMatch(Regexes.preventive2.rawValue).cleanTheTextOf(preventive2BadBits)}
    var psh: String {return chartData.simpleRegExMatch(Regexes.psh.rawValue).cleanTheTextOf(pshBadBits)}
    var pmh: String {return chartData.simpleRegExMatch(Regexes.pmh.rawValue).cleanTheTextOf(pmhBadBits)}
    var lastCharges: String {return chartData.simpleRegExMatch(Regexes.lastCharge.rawValue).cleanTheTextOf(lastChargeBadBits)}
    var lastAppointment:String {return getLastAptInfoFrom(chartData)}
    var nextAppointment:String {return getNextAptInfoFrom(chartData)}
    var aptTime:String
    var aptDate:Int
    var saveLocation:SaveLocation {
        switch aptDate {
        case 0:
            return .dummyFiles
        case 1...4:
            return .tomorrowFiles
        default:
            return .desktop
        }
    }
    
    init(chartData:String, aptTime:String, aptDate:Int) {
        self.chartData = chartData
        self.aptTime = aptTime
        self.aptDate = aptDate
    }
    
    func ptvnOutPut() {
        let finalResults = """
        #PTVNFILE#
        \(SectionDelimiters.planStart.rawValue)
        Next apt: \(nextAppointment)
        \(SectionDelimiters.planEnd.rawValue)
        
        \(SectionDelimiters.pharmacyStart.rawValue)
        
        \(SectionDelimiters.pharmacyEnd.rawValue)
        
        \(SectionDelimiters.assessmentStart.rawValue)
        
        \(SectionDelimiters.assessmentEND.rawValue)
        
        \(SectionDelimiters.objectiveStart.rawValue)
        
        \(SectionDelimiters.objectiveEnd.rawValue)
        
        \(SectionDelimiters.ccStart.rawValue)
        
        \(SectionDelimiters.ccEnd.rawValue)
        
        \(SectionDelimiters.subjectiveStart.rawValue)
        Problems**
        \(lastCharges)
        *problems*
        \(SectionDelimiters.subjectiveEnd.rawValue)
        
        \(SectionDelimiters.rosStart.rawValue)
        
        \(SectionDelimiters.rosEnd.rawValue)
        
        \(SectionDelimiters.medStart.rawValue)
        
        \(SectionDelimiters.medEnd.rawValue)
        
        \(SectionDelimiters.allergiesStart.rawValue)
        \(allergies)
        \(SectionDelimiters.allergiesEnd.rawValue)
        
        \(SectionDelimiters.preventiveStart.rawValue)
        \(preventiveCare)
        \(preventiveCare2)
        \(SectionDelimiters.preventiveEnd.rawValue)
        
        \(SectionDelimiters.pmhStart.rawValue)
        \(pmh)
        \(SectionDelimiters.pmhEnd.rawValue)
        
        \(SectionDelimiters.pshStart.rawValue)
        \(psh)
        \(SectionDelimiters.pshEnd.rawValue)
        
        \(SectionDelimiters.nutritionStart.rawValue)
        \(nutritionalHistory)
        \(SectionDelimiters.nutritionEnd.rawValue)
        
        \(SectionDelimiters.socialStart.rawValue)
        \(socialHistory)
        \(SectionDelimiters.socialEnd.rawValue)
        
        \(SectionDelimiters.familyStart.rawValue)
        \(familyHistory)
        \(SectionDelimiters.familyEnd.rawValue)
        
        \(SectionDelimiters.diagnosisStart.rawValue)
        \(diagnoses)
        \(SectionDelimiters.diagnosisEnd.rawValue)
        
        \(SectionDelimiters.patientNameStart.rawValue)
        \(ptName)
        \(SectionDelimiters.patientNameEnd.rawValue)
        
        \(SectionDelimiters.patientDOBStart.rawValue)
        \(ptDOB)
        \(SectionDelimiters.patientDOBEnd.rawValue)
        
        \(SectionDelimiters.patientAgeStart.rawValue)
        \(ptAge)
        \(SectionDelimiters.patientAgeEnd.rawValue)
        
        \(SectionDelimiters.visitDateStart.rawValue)
        //Will need to bring the date calculation into this class
        \(SectionDelimiters.visitDateEnd.rawValue)
        """
    }
    
    //The regular expressions used to define the desired sections of the text
    enum Regexes:String {
        case social = "(?s)(Social history).*((?<=)Gender identity)"/*"(?s)(Social history).*((?<=)Past medical history)"*/
        case family1 = "(?s)(Family health history).*(Past medical history)"/*"(?s)(Family health history).*(Preventive care)"*/
        case family2 = "(?s)(Family health history).*(Social history)"
        case nutrition1 = "(?s)(Nutrition history).*((?<=)Family health history)"/*"(?s)(Nutrition history).*((?<=)Developmental history)"*/
        case nutrition2 = "(?s)(Nutrition history).*((?<=)Allergies\\n)"
        case diagnoses = "(?s)Diagnoses.*Social\\shistory(?!\\s\\(free\\stext\\))"/*"(?s)Diagnoses.*Social history*?\\s(?=\\nSmoking status*?\\s)"*/
        case medications = "(?s)\\nMedications*\\s+?\\n.*Screenings/ Interventions" /*"(?s)\\nMedications*\\s+?\\n.*Encounters"*/
        case allergies = "(?s)(Developmental\\shistory|Developmental\\shistory\\s+)\\n.*(\\nMedications)" /*"(?s)(\\nAllergies\\n).*(\\nMedications)"*/
        case pmh = "(?s)(Ongoing medical problems).*(Preventive care)" /*"(?s)(Ongoing medical problems).*(Family health history)"*/
        case psh = "(?s)(Major events).*(Ongoing medical problems)"
        case preventive = "(?s)(Preventive care).*Social history" /*"(?s)(Preventive care).*((?<=)Social history)"*/
        case preventive2 = "(?s)Screenings/ Interventions/ Assessments.*Encounters"
        case lastCharge = "(?s)(A\\(Charge\\):).*(Lvl.*\\(done dmw\\))"
        case pharmacy = "(?s)#PHARMACY.*PHARMACY#"
        case newMeds = "(?s)Medications attached to this encounter:.*Orders Print"
        case oldWeight = "Wt:.*lb;\\s*Ht:"
        case pfNoteAssessment = "(?s)(Assessment\\sEdit|[A]ssessment\n-).*Diagnoses attached to this encounter:"
    }
    
    //Get the name, age, and DOB from the text
   private func nameAgeDOB(_ theText: String) -> (String, String, String){
        var ptName = ""
        var ptAge = ""
        var ptDOB = ""
        let theSplitText = theText.components(separatedBy: "\n")
        
        var lineCount = 0
        if !theSplitText.isEmpty {
            for currentLine in theSplitText {
                if currentLine.range(of: "PRN: ") != nil {
                    let ageLine = theSplitText[lineCount + 1]
                    ptName = theSplitText[lineCount - 1]
                    ptAge = ageLine.simpleRegExMatch("^\\d*")
                } else if currentLine.hasPrefix("DOB: "){
                    let dobLine = currentLine
                    ptDOB = dobLine.simpleRegExMatch("\\d./\\d./\\d*")
                }
                lineCount += 1
            }
        }
        return (ptName, ptAge, ptDOB)
    }
    
    //Clean extraneous text from the sections
    private func cleanTheSections(_ theSection:String, badBits:[String]) -> String {
        let textArray = theSection.split(separator: "\n")
        var cleanedText = textArray.filter {$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""}.joined(separator: "\n")
        
        for theBit in badBits {
            cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
        }
        cleanedText = cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return cleanedText
    }
    
    //Get the date of the patients last appointment
    private func getLastAptInfoFrom(_ theText: String) -> String {
        //let unwantedDxs = ["No chief complaint recorded", "CC: Epogen inj", "CC: Testosterone inj", "CC: Flu inj", "CC: Flu Inj", "CC: Udip", "CC: B12 inj", "CC: B12 Inj"]
        let baseSection = theText.findRegexMatchFrom("Encounters", to: "Appointments")
        let encountersSection = baseSection.findRegexMatchBetween("Encounters", and: "Messages")
        //let dateToDateRegex = "(?s)(\\d./\\d./\\d*)(.*?)(\\n)(?=\\d./\\d./\\d*)"
        let dateToEndOfCCLine = "(?m)(\\d./\\d./\\d*)(.*?)(\\n)(CC:.*)"
        
        //If I don't include the map{String($0)} I end up with an array of substrings which can't be used by simpleRegExMatch in the next step
        let activeEncounters = encountersSection.ranges(of: dateToEndOfCCLine, options: .regularExpression).map{encountersSection[$0]}.map{String($0)}.filter {!$0.contains("No chief complaint recorded") &&
            !$0.contains("CC: Epogen inj") &&
            !$0.contains("CC: Testosterone inj") &&
            !$0.contains("CC: Flu inj") &&
            !$0.contains("CC: Flu Inj") &&
            !$0.contains("CC: Udip") &&
            !$0.contains("CC: B12 inj") &&
            !$0.contains("CC: B12 Inj")}
        if activeEncounters.count > 0 {
            let date = activeEncounters[0].simpleRegExMatch("\\d./\\d./\\d*")
            let components = date.components(separatedBy: "/")
            let month = components[0]
            let day = components[1]
            let year = components[2].suffix(2)
            return "\(year)\(month)\(day)"
        } else {
            return "Last apt not found"
        }
    }
    
    private func getNextAptInfoFrom(_ theText: String) -> String {
        let nextAppointments = theText.findRegexMatchBetween("Appointments", and: "View all appointments")
        print(nextAppointments)
        let activeEncounters = nextAppointments.ranges(of: "(?s)(\\w\\w\\w \\d\\d, \\d\\d\\d\\d)(.*?)(\\n)(?=\\w\\w\\w \\d\\d, \\d\\d\\d\\d)", options: .regularExpression).map{nextAppointments[$0]}.map{String($0)}.filter {$0.contains("Pending arrival")}
        if activeEncounters.count > 1 {
            return activeEncounters[1].simpleRegExMatch("\\w\\w\\w \\d\\d, \\d\\d\\d\\d - \\d\\d:\\d\\d \\w\\w")
        } else {
            return "Next apt not found"
        }
    }
}

enum SaveLocation:String {
    case dummyFiles = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
    case tomorrowFiles = "WPCMSharedFiles/zruss Review/Tomorrows Files"
    case desktop = "Desktop"
}

//A struct to get and hold the assessment data from the patient last note
struct OldNoteData {
    var fileURL:URL
    private var theText:String { return fileURL.getTextFromFile() }
    private let lastChargeOld = "(?s)(A\\(Charge\\):).*(Lvl.*\\(done dmw\\))"
    private let lastChargeNew = "(?s)#ASSESSMENT.*ASSESSMENT#"
    var pharmacy:String { return theText.simpleRegExMatch(ChartData.Regexes.pharmacy.rawValue).cleanTheTextOf(["#PHARMACY", "PHARMACY#"])}
    var oldAssessment:String {
        var problem = String()
        if theText.contains("#PTVNFILE#") {
            problem = theText.simpleRegExMatch(lastChargeNew).cleanTheTextOf(lastChargeBadBits)
        } else {
        problem = theText.simpleRegExMatch(lastChargeOld).cleanTheTextOf(lastChargeBadBits)
        }
        let levelBit = problem.simpleRegExMatch("(?s)Lvl.*\\(done dmw\\)")
        problem = problem.replacingOccurrences(of: levelBit, with: "")
        problem = problem.cleanTheTextOf(lastChargeBadBits)
        return problem
    }
    var lastWeight:String { return theText.simpleRegExMatch(ChartData.Regexes.oldWeight.rawValue).cleanTheTextOf(["Wt:", "lb;", "Ht:"])}
}

//Choices to pass into the getFileLabellingNameFrom function
//for how you want the name returned
enum FileLabelType {
    case full
    case firstLast
}

//Using the name line from the PTVN, break it into it's components
//then return it in the format requested per the FileLabelType enum
func getFileLabellingNameFrom(_ name: String, ofType type: FileLabelType) -> String {
    var fileLabellingName = String()
    var ptFirstName = ""
    var ptLastName = ""
    var ptMiddleName = ""
    var ptExtraName = ""
    let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
    
    func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
        var result = false
        for item in arrayToCheckIn {
            if arrayToCheckFor.contains(item) {
                result = true
                break
            }
        }
        return result
    }
    
    let nameComponents = name.components(separatedBy: " ").filter {!$0.contains("(")}
    print("Name components: \(nameComponents)")
    let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
    
    if extraBitsCheck == true {
        ptLastName = nameComponents[nameComponents.count-2]
        ptExtraName = nameComponents[nameComponents.count-1]
    } else {
        ptLastName = nameComponents[nameComponents.count-1]
        ptExtraName = ""
    }
    
    if nameComponents.count > 2 {
        if nameComponents[nameComponents.count - 2] == "Van" {
            ptLastName = "Van " + ptLastName
        }
    }
    
    //Get first name
    ptFirstName = nameComponents[0]
    
    //Get middle name
    if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
        ptMiddleName = ""
    } else {
        ptMiddleName = nameComponents[1]
    }
    if type == FileLabelType.full {
    fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
    } else if type == FileLabelType.firstLast {
        fileLabellingName = "\(ptLastName)\(ptFirstName)"
    }
    let badNameBits = [" ", "-", "'", "(", ")", "\""]
    for bit in badNameBits {
        fileLabellingName = fileLabellingName.replacingOccurrences(of: bit, with: "")
    }
    
    return fileLabellingName
}

