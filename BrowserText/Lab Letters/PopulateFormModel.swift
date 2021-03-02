//
//  PopulateFormModel.swift
//  LabLetters
//
//  Created by Fool on 4/26/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

func processRawData(_ rawData:String) -> RawLabData? {
	//Get the clipboard and turn it into an array of strings representing each line of lab from PF
	//let myPasteboard = NSPasteboard.general
	//guard let copiedText = myPasteboard.string(forType: convertToNSPasteboardPasteboardType("public.utf8-plain-text")) else { return nil }
	let fullText = stripOutExtraWords(rawData, textToRemove: StringValues().extraPhrases)
	let textArray = fullText.components(separatedBy: "\n")
	
	//Create an object to hold the data pulled from the clipboard which can be sent to the view controller
	var currentPatient = RawLabData()
	
	//Find the values of the labs based on their ID strings
	func findLabValue(of idText:String) -> String {
		for (lineNumber, line) in textArray.enumerated() {
			if line.hasPrefix(idText) {
				return textArray[lineNumber + 1]
			}
		}
		return ""
	}
	
	func findHGBValue(of idText:String) -> String {
		let hgbText = stripOutExtraWords(fullText, textToRemove: StringValues().moreExtraPhrases)
		let hgbArray = hgbText.components(separatedBy: "\n")
		for (lineNumber, line) in hgbArray.enumerated() {
			if line.hasPrefix(idText) {
				return hgbArray[lineNumber + 1]
			}
		}
		return ""
	}
	
	//Pull out the patient and date info from textArray and assign it to the currentPatient object
	for (lineNumber, currentLine) in textArray.enumerated() {
		if currentLine.range(of: "COLLECTED") != nil {
			currentPatient.labDateString = getDateRegEx(currentLine)
		}
        if currentLine.range(of: "yrs F") != nil || currentLine.range(of: "yrs M") != nil {
			currentPatient.patientNameString = textArray[lineNumber - 3]
		}
		if currentLine.range(of: "yrs F") != nil {
			currentPatient.patientGenderString = "F"
		} else if currentLine.range(of: "yrs M") != nil {
			currentPatient.patientGenderString = "M"
		}
	}
	
	//Determine the lab modifier based on the labs value
	func getHighLowModifierFor(_ value: String, from valueRange: (lowF:Double, highF:Double, lowM:Double, highM:Double)) -> String {
		//Check if the string contains a less than or greater than sign
		let theValue = removeGreaterLesserSignsFrom(value)
		
		guard let labAsDouble = Double(theValue) else { return "" }
		if currentPatient.patientGenderString == "F" {
			switch labAsDouble {
			case _ where labAsDouble < valueRange.lowF: return LabValue.low.rawValue
			case _ where labAsDouble > valueRange.highF: return LabValue.high.rawValue
			default: return LabValue.normal.rawValue
			}
		} else if currentPatient.patientGenderString == "M" {
			switch labAsDouble {
			case _ where labAsDouble < valueRange.lowM: return LabValue.low.rawValue
			case _ where labAsDouble > valueRange.highM: return LabValue.high.rawValue
			default: return LabValue.normal.rawValue
			}
		}
		return ""
	}
	
	func getTSHModifierFor(_ value:String) -> String {
		//Check if the string contains a less than or greater than sign
		let theValue = removeGreaterLesserSignsFrom(value)
		
		guard let labAsDouble = Double(theValue) else { return "" }
		if currentPatient.patientGenderString == "F" {
			switch labAsDouble {
			case _ where labAsDouble < LabValues().tshValues.lowF: return LabValue.overactive.rawValue
			case _ where labAsDouble > LabValues().tshValues.highF: return LabValue.underactive.rawValue
			default: return LabValue.normal.rawValue
			}
		} else if currentPatient.patientGenderString == "M" {
			switch labAsDouble {
			case _ where labAsDouble < LabValues().tshValues.lowM: return LabValue.overactive.rawValue
			case _ where labAsDouble > LabValues().tshValues.highM: return LabValue.underactive.rawValue
			default: return LabValue.normal.rawValue
			}
		}
		return ""
	}
	
	func getGlucoseModifierFor(_ value:String) -> String {
		//Check if the string contains a less than or greater than sign
		let theValue = removeGreaterLesserSignsFrom(value)
		
		guard let labAsDouble = Double(theValue) else { return "" }
		switch labAsDouble {
		case 0..<65 : return LabValue.low.rawValue
		case 65..<101 : return LabValue.normal.rawValue
		case 101..<105 : return LabValue.borderline.rawValue
		default: return LabValue.high.rawValue
		}
	}
	
	//Create the individual lab data objects
	let wbcValue = findLabValue(of: LabIDs.WBC.rawValue)
	currentPatient.wbcString = "\(wbcValue)\(getHighLowModifierFor(wbcValue, from: LabValues().wbcValues))"
	Swift.print(wbcValue)
	let hgbValue = findHGBValue(of: LabIDs.HEMOGLOBIN.rawValue)
	currentPatient.hgbString = "\(hgbValue)\(getHighLowModifierFor(hgbValue, from: LabValues().hgbValues))"
	let hctValue = findLabValue(of: LabIDs.HEMATOCRIT.rawValue)
	currentPatient.hctString = "\(hctValue)\(getHighLowModifierFor(hctValue, from: LabValues().hctValues))"
	let plateletsValue = findLabValue(of: LabIDs.PLATELETCOUNT.rawValue)
	currentPatient.plateletsString = "\(plateletsValue)\(getHighLowModifierFor(plateletsValue, from: LabValues().plateletsValues))"
	
	let glucoseValue = findLabValue(of: LabIDs.GLUCOSE.rawValue)
	currentPatient.glucoseString = "\(glucoseValue)\(getGlucoseModifierFor(glucoseValue))"
	let creatinineValue = findLabValue(of: LabIDs.CREATININE.rawValue)
	currentPatient.creatinineString = "\(creatinineValue)\(getHighLowModifierFor(creatinineValue, from: LabValues().creatinineValues))"
	let eGFRAAValue = findLabValue(of: LabIDs.eGFRAA.rawValue)
	currentPatient.eGFRAAString = "\(eGFRAAValue)\(getHighLowModifierFor(eGFRAAValue, from: LabValues().eGFRAAValues))"
	let eGFRNonAAValue = findLabValue(of: LabIDs.eGFRNonAA.rawValue)
	currentPatient.eGFRNonAAString = "\(eGFRNonAAValue)\(getHighLowModifierFor(eGFRNonAAValue, from: LabValues().eGFRNonAAValues))"
	let potassiumValue = findLabValue(of: LabIDs.POTASSIUM.rawValue)
	currentPatient.potassiumString = "\(potassiumValue)\(getHighLowModifierFor(potassiumValue, from: LabValues().potassiumValues))"
	let calciumValue = findLabValue(of: LabIDs.CALCIUM.rawValue)
	currentPatient.calciumString = "\(calciumValue)\(getHighLowModifierFor(calciumValue, from: LabValues().calciumValues))"
	
	let proteinValue = findLabValue(of: LabIDs.PROTEIN.rawValue)
	currentPatient.proteinString = "\(proteinValue)\(getHighLowModifierFor(proteinValue, from: LabValues().proteinValues))"
	let albuminValue = findLabValue(of: LabIDs.ALBUMIN.rawValue)
	currentPatient.albuminString = "\(albuminValue)\(getHighLowModifierFor(albuminValue, from: LabValues().albuminValues))"
	let calculatedGlobValue = findLabValue(of: LabIDs.GLOBULIN.rawValue)
	currentPatient.calculatedGlobString = "\(calculatedGlobValue)\(getHighLowModifierFor(calculatedGlobValue, from: LabValues().globValues))"
	let agRatioValue = findLabValue(of: LabIDs.AGRATIO.rawValue)
	currentPatient.agRatioString = "\(agRatioValue)\(getHighLowModifierFor(agRatioValue, from: LabValues().agRatioValues))"
	let bilirubinValue = findLabValue(of: LabIDs.BILIRUBIN.rawValue)
	currentPatient.bilirubinString = "\(bilirubinValue)\(getHighLowModifierFor(bilirubinValue, from: LabValues().biliValues))"
	let alkPhosphataseValue = findLabValue(of: LabIDs.ALKPHOS.rawValue)
	currentPatient.alkPhosphataseString = "\(alkPhosphataseValue)\(getHighLowModifierFor(alkPhosphataseValue, from: LabValues().alkPhosValues))"
	let astValue = findLabValue(of: LabIDs.AST.rawValue)
	currentPatient.astString = "\(astValue)\(getHighLowModifierFor(astValue, from: LabValues().astValues))"
	let altValue = findLabValue(of: LabIDs.ALT.rawValue)
	currentPatient.altString = "\(altValue)\(getHighLowModifierFor(altValue, from: LabValues().altValues))"
	
	currentPatient.hemoglobinA1cString = "\(findLabValue(of: LabIDs.HBA1C.rawValue))"
	currentPatient.averageGlucoseString = "\(findLabValue(of: LabIDs.AVEGLUCOSE.rawValue))"
	
	//Because the Microalbumin result has two different ways of being presented in the DRL results
	//I've cludged this check together
	var microalbuminValue = findLabValue(of: LabIDs.MICROALB1.rawValue)
	if microalbuminValue == "" {
		microalbuminValue = findLabValue(of: LabIDs.MICROALB2.rawValue)
	}
	if microalbuminValue == "(NOTE)" {
		currentPatient.microalbuminString = "Normal"
	} else {
		currentPatient.microalbuminString = "\(microalbuminValue)\(getHighLowModifierFor(microalbuminValue, from: LabValues().microAlbValues))"
	}
	
	currentPatient.totalCholesterolString = "\(findLabValue(of: LabIDs.CHOLESTEROL.rawValue))"
	currentPatient.triglyceridesString = "\(findLabValue(of: LabIDs.TRIGLYCERIDES.rawValue))"
	currentPatient.hdlsString = "\(findLabValue(of: LabIDs.HDL.rawValue))"
	//currentPatient.ldlsString = "\(findLabValue(of: LabIDs.LDL.rawValue))"
	//Check if LDL value is to high to calculate
	let ldlValue = findLabValue(of: LabIDs.LDL.rawValue)
	print(ldlValue)
	if ldlValue == "NOTE" {
		currentPatient.ldlsString = "Unable to calculate."
	} else {
		currentPatient.ldlsString = ldlValue
	}
	
	let ldlConcentrationValue = findLabValue(of: LabIDs.LDLCONC.rawValue)
	currentPatient.ldlConcentrationString = "\(ldlConcentrationValue)\(getHighLowModifierFor(ldlConcentrationValue, from: LabValues().ldlConcValues))"
	let smallLDLValue = findLabValue(of: LabIDs.SMALLLDL.rawValue)
	currentPatient.smallLDLString = "\(smallLDLValue)\(getHighLowModifierFor(smallLDLValue, from: LabValues().smallLDLValues))"
	
	let tshValue = findLabValue(of: LabIDs.TSH.rawValue)
	currentPatient.tshString = "\(tshValue)\(getTSHModifierFor(tshValue))"
	let freeT3Value = findLabValue(of: LabIDs.FREET3.rawValue)
	currentPatient.freeT3String = "\(freeT3Value)\(getHighLowModifierFor(freeT3Value, from: LabValues().freeT3Values))"
	let freeT4Value = findLabValue(of: LabIDs.FREET4.rawValue)
	currentPatient.freeT4String = "\(freeT4Value)\(getHighLowModifierFor(freeT4Value, from: LabValues().freeT4Values))"
	
	let ckTotalValue = findLabValue(of: LabIDs.CK.rawValue)
	currentPatient.ckTotalString = "\(ckTotalValue)\(getHighLowModifierFor(ckTotalValue, from: LabValues().ckValues))"
	let sedRateValue = findLabValue(of: LabIDs.SEDRATE.rawValue)
	currentPatient.sedRateString = "\(sedRateValue)\(getHighLowModifierFor(sedRateValue, from: LabValues().sedValues))"
	let cReactiveProteinValue = findLabValue(of: LabIDs.CREACTIVE.rawValue)
	currentPatient.cReactiveProteinString = "\(cReactiveProteinValue)\(getHighLowModifierFor(cReactiveProteinValue, from: LabValues().cReactiveValues))"
	let cortisolValue = findLabValue(of: LabIDs.CORTISOL.rawValue)
	currentPatient.cortisolString = "\(cortisolValue)\(getHighLowModifierFor(cortisolValue, from: LabValues().cortisolValues))"
	currentPatient.inrString = "\(findLabValue(of: LabIDs.INR.rawValue))"
	
	let vitaminB12Value = findLabValue(of: LabIDs.VITAMINB12.rawValue)
	currentPatient.vitaminB12String = "\(vitaminB12Value)\(getHighLowModifierFor(vitaminB12Value, from: LabValues().b12Values))"
	let vitaminDValue = findLabValue(of: LabIDs.VITAMIND.rawValue)
	currentPatient.vitaminDString = "\(vitaminDValue)\(getHighLowModifierFor(vitaminDValue, from: LabValues().dValues))"
	let ironValue = findLabValue(of: LabIDs.IRON.rawValue)
	currentPatient.ironString = "\(ironValue)\(getHighLowModifierFor(ironValue, from: LabValues().ironValues))"
	let folicAcidValue = findLabValue(of: LabIDs.FOLICACID.rawValue)
	currentPatient.folicAcidString = "\(folicAcidValue)\(getHighLowModifierFor(folicAcidValue, from: LabValues().folicAcidValues))"
	let ferritinValue = findLabValue(of: LabIDs.FERRITIN.rawValue)
	currentPatient.ferritinString = "\(ferritinValue)\(getHighLowModifierFor(ferritinValue, from: LabValues().ferritinValues))"
	let magnesiumValue = findLabValue(of: LabIDs.MAGNESIUM.rawValue)
	currentPatient.magnesiumString = "\(magnesiumValue)\(getHighLowModifierFor(magnesiumValue, from: LabValues().magnesiumValues))"
	
	//Because the Microalbumin result has two different ways of being presented in the DRL results
	//I've cludged this check together
	var psaValue = findLabValue(of: LabIDs.PSA1.rawValue)
	if psaValue == "" {
		psaValue = findLabValue(of: LabIDs.PSA2.rawValue)
	}
    if psaValue == "" {
        psaValue = findLabValue(of: LabIDs.PSA3.rawValue)
    }
	currentPatient.psaString = "\(psaValue)\(getHighLowModifierFor(psaValue, from: LabValues().psaValues))"
	
	let testosteroneValue = findLabValue(of: LabIDs.TESTOSTERONE.rawValue)
	currentPatient.testosteroneString = "\(testosteroneValue)\(getHighLowModifierFor(testosteroneValue, from: LabValues().testosteroneValues))"
	let uricAcidValue = findLabValue(of: LabIDs.URICACID.rawValue)
	currentPatient.uricAcidString = "\(uricAcidValue)\(getHighLowModifierFor(uricAcidValue, from: LabValues().uricAcidValues))"
	let ldhValue = findLabValue(of: LabIDs.LDH.rawValue)
	currentPatient.ldhString = "\(ldhValue)\(getHighLowModifierFor(ldhValue, from: LabValues().ldhValues))"
	let lipaseValue = findLabValue(of: LabIDs.LIPASE.rawValue)
	currentPatient.lipaseString = "\(lipaseValue)\(getHighLowModifierFor(lipaseValue, from: LabValues().lipaseValues))"
	let amylaseValue = findLabValue(of: LabIDs.AMYLASE.rawValue)
	currentPatient.amylaseString = "\(amylaseValue)\(getHighLowModifierFor(amylaseValue, from: LabValues().amylaseValues))"
	
	currentPatient.hPyloriString = "\(findLabValue(of: LabIDs.HPYLORI.rawValue))"
	let rheumatoidFactorValue = findLabValue(of: LabIDs.RHEUMATOID.rawValue)
	currentPatient.rheumatoidFactorString = "\(rheumatoidFactorValue)\(getHighLowModifierFor(rheumatoidFactorValue, from: LabValues().rheumatoidFactorValues))"
	let reticulocyteValue = findLabValue(of: LabIDs.RETICULOCYTE.rawValue)
	currentPatient.reticulocyteString = "\(reticulocyteValue)\(getHighLowModifierFor(reticulocyteValue, from: LabValues().reticulocyteValues))"
	currentPatient.antiNuclearString = "\(findLabValue(of: LabIDs.ANA.rawValue))"
	
	
	//Return the populated RawLabData object
	return currentPatient
	
}

func stripOutExtraWords(_ theTextToClean: String, textToRemove: [String]) -> String {
	var newText = theTextToClean
	for phrase in textToRemove {
		newText = newText.replacingOccurrences(of: phrase, with: "")
	}
	return newText.removeWhiteSpace()
}

func removeGreaterLesserSignsFrom(_ value: String) -> String {
	var theValue = value
	if theValue.contains("<") || theValue.contains(">") {
		//If it does, remove the sign (we're assuming it's the first character)
		theValue = String(theValue.dropFirst())
	}
	return theValue
}

//Take an array of individual labs and create 
func generateSectionWith(heading:String, from labs: [(title: String, value: String)]) -> String? {
	var labArray = [String]()
	var results = String()
	for lab in labs {
		if !lab.value.isEmpty {
			labArray.append("\(lab.title)\(lab.value)")
		}
	}
	if !labArray.isEmpty {
		results = stringOfThreeFromArray(labArray)
		//results = labArray.joined(separator: "    ")
		results = results.prependSectionHeader(heading)
	}
	
	return results
}

func stringOfThreeFromArray(_ startingArray: [String]) -> String {
	var newArray: [String] = [String]()
	var initialArray = startingArray
	
	while initialArray.count > 0 {
		if initialArray.count >= 3 {
			var tempArray = [String]()
			for _ in 1...3 {
				tempArray.append(initialArray.remove(at: 0))
			}
			let tempString = tempArray.joined(separator: "    ")
			newArray.append(tempString)
		} else {
			var tempArray = [String]()
			for _ in 1...initialArray.count {
				tempArray.append(initialArray.remove(at: 0))
			}
			let tempString = tempArray.joined(separator: "    ")
			newArray.append(tempString)
		}
	}
	
	let stringResult = newArray.joined(separator: "\n")
	
	return stringResult
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}
