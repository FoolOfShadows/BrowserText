//
//  LabsModel.swift
//  LIROS
//
//  Created by Fool on 10/30/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Foundation

let headerInfo = (/*"Whelchel Primary Care Medicine" + "\n" + "401 East Pinecrest, Marshall, TX  75670" + "\n" + */"CPL Client #: 36686"/* + "\n" + "Phone: 903-935-7101     Fax: 903-935-7043"*/)

var whereFlu = [""]
var declinesFlu = [""]

protocol populateComboBoxProtocol {
    func matchValuesFrom(_ id:Int) -> [String]?
}

struct Patient {
    var theText:String
    var ptInnerName: String { return nameAgeDOB(theText).0}
    var ptLabelName: String {return getFileLabellingName(ptInnerName)}
    var ptDOB: String { return nameAgeDOB(theText).2}
    
    private func nameAgeDOB(_ theText: String) -> (String, String, String){
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
        print(ptName, ptAge, ptDOB)
        return (ptName, ptAge, ptDOB)
        
    }
}

struct Labs {
    func getOutputFor(_ id:Int) -> String? {
        switch id {
        case 1: return "BMP"
        case 2: return "CMP"
        case 3: return "CBC"
        case 4: return "TSH"
        case 5: return "Free T4"
        case 6: return "Free T3"
        case 7: return "Vitamin D"
        case 8: return "Uric Acid"
        case 9: return "CPK"
        case 10: return "ESR"
        case 11: return "CRP"
        case 12: return "RF"
        case 13: return "Free PSA"
        case 14: return "HSV1/HSV2"
        case 15: return "RPR"
        case 16: return "Clamydia"
        case 17: return "Lipids"
        case 18: return "PSA"
        case 19: return "Urine dip"
        case 20: return "Urine Culture"
        case 21: return "UDS"
        case 22: return "UCG"
        case 23: return "PTT"
        case 24: return "FSH"
        case 25: return "Testosterone"
        case 26: return "ANA"
        case 27: return "Vitamin B12"
        case 28: return "H Pylori"
        case 29: return "PAP Smear"
        case 30: return "HIV"
        case 31: return "Gonorhea"
        case 32: return "NMR Lipids"
        case 33: return "HbA1c"
        case 34: return "Urine Microalbumin"
        case 35: return "Urine Micro Analysis"
        case 36: return "m UDS"
        case 37: return "Urine Protein/Creatinine"
        case 38: return "PT/INR"
        case 39: return "Hormone Panel (FSH, LH, Progesterone, Prolactin, Estradiol, Testosterone)"
        case 40: return "Free Testosterone"
        case 41: return "ANA Panel (SSA/SSB, SCL/70, Centromere AB, Jo-1 Antibody, RA, ANA, C3, C4, DNA AB DS, Thyroid Peroxidase AB)"
        case 42: return "Anemia Panel (CBC, Ferritin, Folic Acid, Iron/TIBC, LDH, Retic, B12)"
        case 43: return "Cortisol"
        case 44: return "Stool studies"
        case 45: return "Comprehensive hepatitis panel"
        case 46: return "Acute hepatitis panel"
        default: return nil
        }
    }
	
	func getPrintOutputFor(_ id:Int) -> String? {
		switch id {
		case 1: return "Basic Metabolic Panel (BMP)"
		case 2: return "Complete Metabolic Panel (CMP)"
		case 3: return "Complete Blood Count with Differential (CBC)"
		case 4: return "Thyroid Stimulating Hormone (TSH)"
		case 5: return "Free Thyroxine Level (T4F)"
		case 6: return "Free Triiodothyronine Level (T3F)"
		case 7: return "Vitamin D Total (25 Hydroxy)"
		case 8: return "Uric Acid"
		case 9: return "Creatine Kinase (CPK)"
		case 10: return "Erythrocyte Sedimentation Rate (ESR)"
		case 11: return "C-Reactive Protien (CRP)"
		case 12: return "Rheumatoid Factor (RF)"
		case 13: return "Free Prostate Specific Antigen (FPSA)"
		case 14: return "HSV1/HSV2"
		case 15: return "RPR"
		case 16: return "Clamydia"
		case 17: return "Lipid Panel"
		case 18: return "Prostate Specific Antigen (PSA)"
		case 19: return "Urine dip"
		case 20: return "Urine Culture & Sensitivities"
		case 21: return "Urine Drug Screen (UDS)"
		case 22: return "UCG"
		case 23: return "Partial Thromboplastin Time (PTT)"
		case 24: return "Follicle Stimulating Hormone (FSH)"
		case 25: return "Total Testosterone"
		case 26: return "Antinuclear Anibody Titer & Pattern (ANA)"
		case 27: return "Cyanocobalamin Level (Vitamin B12)"
		case 28: return "Helicobacter Pylori Antibody Panel (H Pylori)"
		case 29: return "Papanicolaou Smear (PAP)"
		case 30: return "HIV"
		case 31: return "Gonorhea"
		case 32: return "NMR Lipid Panel"
		case 33: return "Hemoglobin A1c w/EAG (HbA1c)"
		case 34: return "Urine Microalbumin/Creatinine Ratio"
		case 35: return "Urine Microscopic"
		case 36: return "m UDS"
		case 37: return "Urine Protein/Creatinine Ratio"
		case 38: return "Protime w/International Normalizing Ration (PT/INR)"
		case 39: return "Hormone Panel (Follicle Stimulating Hormone, Luteinizing Hormone, Progesterone, Prolactin, Estradiol, Testosterone)"
		case 40: return "Free Testosterone"
		case 41: return "ANA Panel (SSA/SSB, SCL/70, Centromere AB, Jo-1 Antibody, RA, ANA, C3, C4, DNA AB DS, Thyroid Peroxidase AB)"
		case 42: return "Anemia Panel (CBC, Ferritin, Folic Acid, Iron/TIBC, LDH, Retic, B12)"
		case 43: return "Cortisol Level"
		case 44: return "Stool Studies (Stool Culture, Ova & Parasites, C Diff Ag/Toxin, Fecal WBC)"
		case 45: return "Comprehensive hepatitis panel"
		case 46: return "Acute hepatitis panel"
		default: return nil
		}
	}
	
	
    func getOutputFor(_ tag:Int, description:String) {
        
    }
    
    func processLabDataForNote(_ data:[(Int, String?)]) -> [String] {
        var resultArray = [String]()
        
        for item in data {
            guard let dx = item.1, !dx.isEmpty else { continue }
            if let theLab = getOutputFor(item.0) {
                resultArray.append(theLab)
            }
        }

        return resultArray
    }
    
    func processLabDataForPrint(_ data:[(Int, String?)]) -> [String] {
        var resultArray = [String]()
        
        for item in data {
            guard let dx = item.1, !dx.isEmpty else { continue }
            if let theLab = getPrintOutputFor(item.0) {
                let printLab = "\(theLab) - \(dx)"
                resultArray.append(printLab)
            }
        }

        return resultArray
    }
    
    func getFluShotStatusFrom(_ data: [(Int, String?)]) -> String? {
        var declineReason = ""
        var willGetAt = ""
        var didGetAt = ""
        var didGetOn = ""
        
        for item in data {
            switch item.0 {
            case 10: declineReason = ": \(item.1!)"
            case 11: willGetAt = " at \(item.1!)"
            case 12: didGetAt = " at \(item.1!)"
            case 15: didGetOn = ": \(item.1!)"
            default: continue
            }
        }
        
        var results:String?
        for item in data {
            switch item.0 {
            case 1: results = "Patient has already received the flu vaccine here."
            case 2: results = "Patient declines flu shot\(declineReason)."
            case 3: results = "Patient will get flu vaccine\(willGetAt)."
            case 4: results = "Patient received flu vaccine\(didGetAt)\(didGetOn)."
            default: continue
            }
        }
        
        
        return results
    }
}

struct FluComboboxValues: populateComboBoxProtocol {
    func matchValuesFrom(_ id: Int) -> [String]? {
        switch id {
        case 10: return declinesFlu
        case 11, 12: return whereFlu
        default: return ["No matching values found."]
        }
    }
    
    
}

struct LabDxValues: populateComboBoxProtocol {
    func matchValuesFrom(_ id:Int) -> [String]? {
        switch id {
        case 1/*bmpDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "I10 HTN", "E11.9 DMII", "E11.65", "N18.9"]
        case 2/*cmpDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "I10 HTN", "E11.9 DMII", "N18.9", "R10.9"]
        case 3/*cbcDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "D53.9", "D51.0", "D51.8 B12O", "D51.1 B12Mal", "D50.9", "R53.83 FatigO", "R53.1 Wk", "R53.81 Malais", "G93.3 FatigPV", "J44.9"]
        case 4/*tshDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E03.9 LothyU", "R53.83 FatigO", "R53.1 Wk", "R53.81 Malais", "G93.3 FatigPV"]
        case 5/*ft4DxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E03.9 LothyU", "R53.83 FatigO", "R53.1 Wk", "R53.81 Malais", "G93.3 FatigPV"]
        case 6/*ft3DxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E03.9 LothyU", "R53.83 FatigO", "R53.1 Wk", "R53.81 Malais", "G93.3 FatigPV"]
        case 7/*vitDDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E55.9 Def", "M81.00", "M89.9 Ostpn", "E63.9"]
        case 8/*urACDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M10.00 Gout", "M10.9", "M25.50"]
        case 9/*cpkDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M79.1 Myalg", "M79.7 Fmyalg"]
        case 10/*esrDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M25.50", "M79.1 Myalg", "M79.7 Fmyalg", "R51 HA", "G44.1 VHA"]
        case 11/*crpDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M25.50", "M79.1 Myalg", "M79.7 Fmyalg"]
        case 12/*rfDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M25.50", "M06.9"]
        case 13/*fpsaDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M25.50", "M06.9"]
        case 14/*hsvDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 15/*rprDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 16/*clamDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 17/*lpdDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E78.00 PurHC", "E78.49 OthLpd", "E78.2 LpdMx", "E78.0 LpdChl", "E11.9 DMII", "E11.65"]
        case 18/*psaDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "Z12.5 PSAScrn", "N40.0", "600.01", "C61"]
        case 19/*udipDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "R35.0 U Freq", "R39.15 U Urg", "R30.0 Dysur", "R30.9 PainUr", "788.31", "R35.1 Nocturia", "N39.0 UTI", "R31.0", "R31.2 McrHemU"]
        case 20/*ucxDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "N39.0 UTI"]
        case 21/*udsDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 22/*ucgDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "625.9"]
        case 23/*pttDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "R23.3", "Z01.812 PreOp", "Z01.818 PreOpOther", "451.2", "I50.9", "427.3", "435.9"]
        case 24/*fshDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "N95.1", "N92.4", "N95.0", "N95.8", "628.0", "256.4", "E29.1 Tst Hypo"]
        case 25/*tstDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E29.1 Tst Hypo"]
        case 26/*anaDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M25.50", "M79.1 Myalg", "M79.7 Fmyalg"]
        case 27/*b12DxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "D53.9", "D51.0", "D51.8 B12O", "D51.1 B12Mal", "D50.9", "K14.0", "R26.89 GaitAb", "R26.0 Atax", "R26.1 GaitParlyz"]
        case 28/*hpylDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "K21.9 GERD"]
        case 29/*papDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "K21.9 GERD"]
        case 30/*hivDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 31/*gonDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 32/*lpdnmrDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E78.4 LpdO", "E78.2 LpdMx", "E78.0 LpdChl", "E11.9 DMII", "E11.65"]
        case 33/*hba1cDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E11.9 DMII", "E11.65", "250.01", "250.03", "R73.09 AbGlu"]
        case 34/*umalbDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E11.9 DMII", "E11.65", "250.01", "250.03", "I10 HTN", "N18.9"]
        case 35/*uamicDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "R31.0", "R31.29 McrHemU"]
        case 36/*mudsDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 37/*uprcrDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "N18.9", "R80.9 PrtnUr", "E11.9 DMII", "I10 HTN"]
        case 38/*ptinrDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "Z79.01 AnticoagUse", "R23.3", "Z01.812 PreOp", "Z01.818 PreOpOther"]
        case 39/*hrmpnlDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "N95.1", "N92.4", "N95.0", "N95.8", "628.0", "256.4", "E29.1 Tst Hypo"]
        case 40/*ftstDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "E29.1 Tst Hypo"]
        case 41/*anapnlDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "M25.50", "M79.1 Myalg", "M79.7 Fmyalg", "714.9", "M32.10"]
        case 42/*anemiapnlDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "D53.9", "D51.0", "D51.8 B12O", "D51.1 B12Mal", "D50.9"]
        case 43/*cortisolDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "R53.83 FatigO", "R53.1 Wk", "R53.81 Malais", "G93.3 FatigPV", "R63.5", "R63.4"]
        case 44/*stoolDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00", "R53.83 FatigO", "R53.1 Wk", "R53.81 Malais", "G93.3 FatigPV", "R19.7 Diarhea", "R63.5", "R63.4"]
        case 45/*cheppnlDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 46/*aheppnlDxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 47/*other1DxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        case 48/*other2DxValues*/: return ["", "Z79.899 MedUse", "Z79.891 MedOpi", "Z00.00"]
        default: return ["Error assigning diagnosis values"]
        }
    }
}


