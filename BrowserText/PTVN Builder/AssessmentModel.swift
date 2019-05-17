//
//  AssessmentModel.swift
//  PTVN Editor
//
//  Created by Fool on 10/17/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Foundation

enum SectionHeadings: String, CaseIterable {
    case GENERAL = "GENERAL:"
    case PSY = "PSY:"
    case HEAD = "HEAD:"
    case EYE = "EYE:"
    case ENT = "ENT:"
    case NOSE = "NOSE:"
    case THROAT = "THROAT:"
    case NECK = "NECK:"
    case CV = "CV:"
    case CHEST = "CHEST:"
    case GI = "GI:"
    case LYMPH = "LYMPH:"
    case EXTREMITIES = "EXTREMITIES:"
    case NEURO = "NEURO:"
    case MSK = "MSK:"
    case SKIN = "SKIN:"
    case VIBE = "Vibration\\sSense\\s-"
    case MONO = "Monofilament\\s-"
}

struct PhysicalAssessment {
    var objectiveText:String
    var genSection:String { return getAssessmentSectionFor(SectionHeadings.GENERAL.rawValue) }
    var psySection:String { return getAssessmentSectionFor(SectionHeadings.PSY.rawValue) }
    var headSection:String { return getAssessmentSectionFor(SectionHeadings.HEAD.rawValue) }
    var eyeSection:String { return getAssessmentSectionFor(SectionHeadings.EYE.rawValue) }
    var entSection:String { return getAssessmentSectionFor(SectionHeadings.ENT.rawValue) }
    var noseSection:String { return getAssessmentSectionFor(SectionHeadings.NOSE.rawValue) }
    var throatSection:String { return getAssessmentSectionFor(SectionHeadings.THROAT.rawValue) }
    var neckSection:String { return getAssessmentSectionFor(SectionHeadings.NECK.rawValue) }
    var cvSection:String { return getAssessmentSectionFor(SectionHeadings.CV.rawValue) }
    var chestSection:String { return getAssessmentSectionFor(SectionHeadings.CHEST.rawValue) }
    var giSection:String { return getAssessmentSectionFor(SectionHeadings.GI.rawValue) }
    var lymphSection:String { return getAssessmentSectionFor(SectionHeadings.LYMPH.rawValue) }
    var vibeSection:String { return getAssessmentSectionFor(SectionHeadings.VIBE.rawValue) }
    var monoSection:String { return getAssessmentSectionFor(SectionHeadings.MONO.rawValue) }
    var extSection:String { return getAssessmentSectionFor(SectionHeadings.EXTREMITIES.rawValue) }
    var neuroSection:String { return getAssessmentSectionFor(SectionHeadings.NEURO.rawValue) }
    var mskSection:String { return getAssessmentSectionFor(SectionHeadings.MSK.rawValue) }
    var skinSection:String { return getAssessmentSectionFor(SectionHeadings.SKIN.rawValue) }
    var nonPEObjective:String { return cleanObjectiveOfAssessment()}
    
    var allPASections:[String] { return [mskSection, genSection, psySection, headSection, eyeSection, entSection, noseSection, throatSection, neckSection, cvSection, chestSection, giSection, lymphSection, extSection, neuroSection, skinSection]}
    
    func getAssessmentSectionFor(_ header:String) -> String {
        let bitsToClean:[String] = { SectionHeadings.allCases.map {$0.rawValue}.filter {$0 != header && $0 != SectionHeadings.VIBE.rawValue && $0 != SectionHeadings.MONO.rawValue}}()
        switch header {
        case SectionHeadings.VIBE.rawValue, SectionHeadings.MONO.rawValue:
            return objectiveText.simpleRegExMatch("(?s)\(header).*?(\\n\\n|[A-Z]{2,}?:|,|\\z)").removeWhiteSpace().cleanTheTextOf(bitsToClean + [","])
//        case SectionHeadings.GI.rawValue:
//            return objectiveText.simpleRegExMatch("(?s)\(header).*?(\\n\\n|[A-Z]{2,}?:|\\z)(?<!ABDOMEN:)").removeWhiteSpace().cleanTheTextOf(bitsToClean)
//        case SectionHeadings.ENT.rawValue:
//            return objectiveText.simpleRegExMatch("(?s)\(header).*?(\\n\\n|[A-Z]{2,}?:|\\z)(?<!EARS:)(?<!EAC:)").removeWhiteSpace().cleanTheTextOf(bitsToClean + [", "])
        default:
        //The regex here looks for text matching between the section heading value and either
        //two returns, two or more capital letters together with a colon (the next heading)
        //or the end of the section.  It also includes a negative assertion to ignore the
        //subheading "EARS:"
        return objectiveText.simpleRegExMatch("(?s)\(header).*?(\\n\\n|[A-Z]{2,}?:|\\z)(?<!EARS:)(?<!EAC:)(?<!ABDOMEN:)(?<!BS:)").removeWhiteSpace().cleanTheTextOf(bitsToClean)
        }
    }
    
    func cleanAssessmentForXFR() -> String {
        var finalNeuro = [neuroSection, vibeSection, monoSection].filter { !$0.isEmpty }.joined(separator: ", ")
        if !finalNeuro.isEmpty && !finalNeuro.contains("NEURO:") {
            finalNeuro = "NEURO: " + finalNeuro
        }
        
        var finalExt = extSection.cleanTheTextOf([vibeSection, monoSection, " ,"])
        if finalExt.last == "," {
            finalExt.popLast()
        }
        
        let orderedArray = [nonPEObjective, genSection, psySection, headSection, eyeSection, entSection, noseSection, throatSection, neckSection, cvSection, chestSection, giSection, lymphSection, finalExt, finalNeuro, mskSection, skinSection]
        
        let finalArray = orderedArray.filter { !$0.isEmpty }
        //print("Gen: \(genSection)\nExt: \(finalExt)\nNeuro: \(finalNeuro)")
        //print(finalArray.joined(separator: "\n"))
        return finalArray.joined(separator: "\n")
    }
    
    //
    func cleanObjectiveOfAssessment() -> String {
        var localObjective = objectiveText
        //print("extSection: \(extSection)")
        for section in allPASections {
            localObjective = localObjective.replacingOccurrences(of: section, with: "")
        }
        return localObjective.replaceRegexPattern("\\n{2,}", with: "\n")
    }
}
