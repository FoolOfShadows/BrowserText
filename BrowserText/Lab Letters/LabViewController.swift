//
//  ViewController.swift
//  LabLetters
//
//  Created by Fool on 4/11/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class LabViewController: NSViewController {

	@IBOutlet weak var labLetterMainWindow: NSWindow!
	@IBOutlet var labLetterMainView: NSView!
	//Blood Count
	@IBOutlet weak var letterDateView: NSTextField!
	@IBOutlet weak var patientNameView: NSTextField!
	@IBOutlet weak var labDateView: NSTextField!
	@IBOutlet weak var wbcView: NSTextField!
	@IBOutlet weak var hgbView: NSTextField!
	@IBOutlet weak var hctView: NSTextField!
	@IBOutlet weak var plateletsView: NSTextField!
	//CBC
	@IBOutlet weak var glucoseView: NSTextField!
	@IBOutlet weak var creatinineView: NSTextField!
	@IBOutlet weak var eGFRAAView: NSTextField!
	@IBOutlet weak var eGFRNonAAView: NSTextField!
	@IBOutlet weak var potassiumView: NSTextField!
	@IBOutlet weak var calciumView: NSTextField!
	//Liver Function
	@IBOutlet weak var proteinView: NSTextField!
	@IBOutlet weak var albuminView: NSTextField!
	@IBOutlet weak var calculatedGlobView: NSTextField!
	@IBOutlet weak var agRatioView: NSTextField!
	@IBOutlet weak var bilirubinView: NSTextField!
	@IBOutlet weak var alkPhosphataseView: NSTextField!
	@IBOutlet weak var astView: NSTextField!
	@IBOutlet weak var altView: NSTextField!
	//Diabetic Labs
	@IBOutlet weak var hemoglobinA1cView: NSTextField!
	@IBOutlet weak var averageGlucoseView: NSTextField!
	@IBOutlet weak var microalbuminView: NSTextField!
	//Cholesterol
	@IBOutlet weak var totalCholesterolView: NSTextField!
	@IBOutlet weak var triglyceridesView: NSTextField!
	@IBOutlet weak var hdlsView: NSTextField!
	@IBOutlet weak var ldlsView: NSTextField!
	@IBOutlet weak var ldlConcentrationView: NSTextField!
	@IBOutlet weak var smallLDLView: NSTextField!
	//Thyroid
	@IBOutlet weak var tshView: NSTextField!
	@IBOutlet weak var freeT3View: NSTextField!
	@IBOutlet weak var freeT4View: NSTextField!
	//Other 1
	@IBOutlet weak var ckTotalView: NSTextField!
	@IBOutlet weak var sedRateView: NSTextField!
	@IBOutlet weak var cReactiveProteinView: NSTextField!
	@IBOutlet weak var cortisolView: NSTextField!
	@IBOutlet weak var inrView: NSTextField!
	//Vitamin Levels
	@IBOutlet weak var vitaminB12View: NSTextField!
	@IBOutlet weak var vitaminDView: NSTextField!
	@IBOutlet weak var ironView: NSTextField!
	@IBOutlet weak var folicAcidView: NSTextField!
	@IBOutlet weak var ferritinView: NSTextField!
	@IBOutlet weak var magnesiumView: NSTextField!
	//Other 2
	@IBOutlet weak var psaView: NSTextField!
	@IBOutlet weak var testosteroneView: NSTextField!
	@IBOutlet weak var uricAcidView: NSTextField!
	@IBOutlet weak var ldhView: NSTextField!
	@IBOutlet weak var lipaseView: NSTextField!
	@IBOutlet weak var amylaseView: NSTextField!
	//Other 3
	@IBOutlet weak var hPyloriView: NSTextField!
	@IBOutlet weak var rheumatoidFactorView: NSTextField!
	@IBOutlet weak var antiNuclearView: NSTextField!
	@IBOutlet weak var reticulocyteView: NSTextField!
	//Other 4
	@IBOutlet weak var other1View: NSTextField!
	@IBOutlet weak var other2View: NSTextField!
	@IBOutlet weak var other3View: NSTextField!
	@IBOutlet weak var other4View: NSTextField!
	@IBOutlet weak var other5View: NSTextField!
	@IBOutlet weak var other6View: NSTextField!

    var rawLabData = String()
    var finalLabData = String()
    
    weak var viewDataDelegate: webViewDataProtocol?
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		letterDateView.stringValue = currentDateLong()
	
	}
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let theWindow = self.view.window {
            theWindow.title = "Lab Letter"
            //This removes the ability to resize the window of a view
            //opened by a segue
            theWindow.styleMask.remove(.resizable)
            //This makes the window float at the front of the other windows
            //Does the staff want this window to float? - no 5/23/19
            //theWindow.level = .floating
            theWindow.setFrameUsingName("labLetterWindow")
            theWindow.windowController!.windowFrameAutosaveName = "labLetterWindow"
        }
        populateFromClipboard(self)
    }
	
	@IBAction func clearForm(_ sender: NSButton) {
		labLetterMainView.clearControllers()
		letterDateView.stringValue = currentDateLong()
	}

	@IBAction func populateFromClipboard(_ sender: Any?) {
		//Generate an object with the processed lab data from the contents of the clipboard
        guard let extractedLabData = processRawData(rawLabData) else { return }
		
		//Populate the TextFields of the form with the data from the processed lab object
		patientNameView.stringValue = extractedLabData.patientNameString ?? ""
		labDateView.stringValue = extractedLabData.labDateString ?? ""
		
		wbcView.stringValue = extractedLabData.wbcString ?? ""
		hgbView.stringValue = extractedLabData.hgbString ?? ""
		hctView.stringValue = extractedLabData.hctString ?? ""
		plateletsView.stringValue = extractedLabData.plateletsString ?? ""
		
		glucoseView.stringValue = extractedLabData.glucoseString ?? ""
		creatinineView.stringValue = extractedLabData.creatinineString ?? ""
		eGFRAAView.stringValue = extractedLabData.eGFRAAString ?? ""
		eGFRNonAAView.stringValue = extractedLabData.eGFRNonAAString ?? ""
		potassiumView.stringValue = extractedLabData.potassiumString ?? ""
		calciumView.stringValue = extractedLabData.calciumString ?? ""
		
		proteinView.stringValue = extractedLabData.proteinString ?? ""
		albuminView.stringValue = extractedLabData.albuminString ?? ""
		calculatedGlobView.stringValue = extractedLabData.calculatedGlobString ?? ""
		agRatioView.stringValue = extractedLabData.agRatioString ?? ""
		bilirubinView.stringValue = extractedLabData.bilirubinString ?? ""
		alkPhosphataseView.stringValue = extractedLabData.alkPhosphataseString ?? ""
		astView.stringValue = extractedLabData.astString ?? ""
		altView.stringValue = extractedLabData.altString ?? ""
		
		hemoglobinA1cView.stringValue = extractedLabData.hemoglobinA1cString ?? ""
		averageGlucoseView.stringValue = extractedLabData.averageGlucoseString ?? ""
		microalbuminView.stringValue = extractedLabData.microalbuminString ?? ""
		
		totalCholesterolView.stringValue = extractedLabData.totalCholesterolString ?? ""
		triglyceridesView.stringValue = extractedLabData.triglyceridesString ?? ""
		hdlsView.stringValue = extractedLabData.hdlsString ?? ""
		ldlsView.stringValue = extractedLabData.ldlsString ?? ""
		ldlConcentrationView.stringValue = extractedLabData.ldlConcentrationString ?? ""
		smallLDLView.stringValue = extractedLabData.smallLDLString ?? ""
		
		tshView.stringValue = extractedLabData.tshString ?? ""
		freeT3View.stringValue = extractedLabData.freeT3String ?? ""
		freeT4View.stringValue = extractedLabData.freeT4String ?? ""
		
		ckTotalView.stringValue = extractedLabData.ckTotalString ?? ""
		sedRateView.stringValue = extractedLabData.sedRateString ?? ""
		cReactiveProteinView.stringValue = extractedLabData.cReactiveProteinString ?? ""
		cortisolView.stringValue = extractedLabData.cortisolString ?? ""
		inrView.stringValue = extractedLabData.inrString ?? ""
		
		vitaminB12View.stringValue = extractedLabData.vitaminB12String ?? ""
		vitaminDView.stringValue = extractedLabData.vitaminDString ?? ""
		ironView.stringValue = extractedLabData.ironString ?? ""
		folicAcidView.stringValue = extractedLabData.folicAcidString ?? ""
		ferritinView.stringValue = extractedLabData.ferritinString ?? ""
		magnesiumView.stringValue = extractedLabData.magnesiumString ?? ""
		
		psaView.stringValue = extractedLabData.psaString ?? ""
		testosteroneView.stringValue = extractedLabData.testosteroneString ?? ""
		uricAcidView.stringValue = extractedLabData.uricAcidString ?? ""
		ldhView.stringValue = extractedLabData.ldhString ?? ""
		lipaseView.stringValue = extractedLabData.lipaseString ?? ""
		amylaseView.stringValue = extractedLabData.amylaseString ?? ""
		
		hPyloriView.stringValue = extractedLabData.hPyloriString ?? ""
		rheumatoidFactorView.stringValue = extractedLabData.rheumatoidFactorString ?? ""
		reticulocyteView.stringValue = extractedLabData.reticulocyteString ?? ""
		antiNuclearView.stringValue = extractedLabData.antiNuclearString ?? ""
		
		//Detect the values which are out of range and color them red
		//so they're easier to detect during the check process
		labLetterMainView.highlightOutOfRangeResults()
	}
	
	@IBAction func processToClipboard(_ sender: Any) {
		//Create the different sections of the letter
		let ltrSalutation = "\(letterDateView.stringValue)\n\nDear \(patientNameView.stringValue), \n\nThese are the results of your lab drawn on \(labDateView.stringValue)."
		
		let bloodCountResults = generateSectionWith(heading: "     Blood count", from: [(LabIDs.WBC.outputTitle, wbcView.stringValue), (LabIDs.HEMOGLOBIN.outputTitle, hgbView.stringValue), (LabIDs.HEMATOCRIT.outputTitle, hctView.stringValue), (LabIDs.PLATELETCOUNT.outputTitle, plateletsView.stringValue)]) ?? ""
		let cholesterolResults = generateCholesterolSection()
		let diabeticResults = generateDiabticLabSection()
		let cbcResults = generateSectionWith(heading: "     Complete Metabolic Panel", from: [(LabIDs.GLUCOSE.outputTitle, glucoseView.stringValue), (LabIDs.CREATININE.outputTitle, creatinineView.stringValue), (LabIDs.POTASSIUM.outputTitle, potassiumView.stringValue), (LabIDs.eGFRAA.outputTitle, eGFRAAView.stringValue), (LabIDs.eGFRNonAA.outputTitle, eGFRNonAAView.stringValue), (LabIDs.CALCIUM.outputTitle, calciumView.stringValue)]) ?? ""
		let liverResults = generateSectionWith(heading: "     Liver Panel", from: [(LabIDs.PROTEIN.outputTitle, proteinView.stringValue), (LabIDs.ALBUMIN.outputTitle, albuminView.stringValue), (LabIDs.GLOBULIN.outputTitle, calculatedGlobView.stringValue), (LabIDs.AGRATIO.outputTitle, agRatioView.stringValue), (LabIDs.BILIRUBIN.outputTitle, bilirubinView.stringValue), (LabIDs.ALKPHOS.outputTitle, alkPhosphataseView.stringValue), (LabIDs.AST.outputTitle, astView.stringValue), (LabIDs.ALT.outputTitle, altView.stringValue)]) ?? ""
		let thyroidResults = generateSectionWith(heading: "     Thyroid Function", from: [(LabIDs.TSH.outputTitle, tshView.stringValue), (LabIDs.FREET3.outputTitle, freeT3View.stringValue), (LabIDs.FREET4.outputTitle, freeT4View.stringValue)]) ?? ""
		let otherResults = generateSectionWith(heading: "     Other", from: [(LabIDs.CK.outputTitle, ckTotalView.stringValue), (LabIDs.SEDRATE.outputTitle, sedRateView.stringValue), (LabIDs.CREACTIVE.outputTitle, cReactiveProteinView.stringValue), (LabIDs.CORTISOL.outputTitle, cortisolView.stringValue), (LabIDs.INR.outputTitle, inrView.stringValue), (LabIDs.VITAMINB12.outputTitle, vitaminB12View.stringValue), (LabIDs.FOLICACID.outputTitle, folicAcidView.stringValue), (LabIDs.VITAMIND.outputTitle, vitaminDView.stringValue), (LabIDs.IRON.outputTitle, ironView.stringValue), (LabIDs.FERRITIN.outputTitle, ferritinView.stringValue), (LabIDs.MAGNESIUM.outputTitle, magnesiumView.stringValue), (LabIDs.PSA1.outputTitle, psaView.stringValue), (LabIDs.TESTOSTERONE.outputTitle, testosteroneView.stringValue), (LabIDs.URICACID.outputTitle, uricAcidView.stringValue), (LabIDs.LDH.outputTitle, ldhView.stringValue), (LabIDs.LIPASE.outputTitle, lipaseView.stringValue), (LabIDs.AMYLASE.outputTitle, amylaseView.stringValue), (LabIDs.HPYLORI.outputTitle, hPyloriView.stringValue), (LabIDs.RHEUMATOID.outputTitle, rheumatoidFactorView.stringValue), (LabIDs.ANA.outputTitle, antiNuclearView.stringValue), (LabIDs.RETICULOCYTE.outputTitle, reticulocyteView.stringValue), (LabIDs.OTHER.outputTitle, other1View.stringValue), (LabIDs.OTHER.outputTitle, other2View.stringValue), (LabIDs.OTHER.outputTitle, other3View.stringValue), (LabIDs.OTHER.outputTitle, other4View.stringValue), (LabIDs.OTHER.outputTitle, other5View.stringValue), (LabIDs.OTHER.outputTitle, other6View.stringValue)])
		let ltrClosing = "Please call my office to make an appointment if you have any questions about these results.\nSincerely,\n\nDawn R. Whelchel, M.D."
		
		//Concatenate the sections into a unified string
		let bodySections = [ltrSalutation, bloodCountResults, cholesterolResults, diabeticResults, cbcResults, liverResults, thyroidResults, otherResults, ltrClosing]
		var populatedSections = [String]()
		for section in bodySections {
			if !section!.isEmpty {
				populatedSections.append(section!)
			}
		}
		
		let finalLetter = populatedSections.joined(separator: "\n\n")
		
		//Pass the final letter string to the clipboard
		let pasteBoard = NSPasteboard.general
		pasteBoard.clearContents()
		pasteBoard.setString(finalLetter, forType: NSPasteboard.PasteboardType.string)
        finalLabData = finalLetter
        self.view.window?.performClose(self)
	}
	
	func generateDiabticLabSection() -> String {
		var diabeticLabString = String()
		if !hemoglobinA1cView.stringValue.isEmpty {
			diabeticLabString += "Hemoglobin A1c: \(hemoglobinA1cView.stringValue). The goal is less than 7 and normal is less than 6. "
		}
		if !averageGlucoseView.stringValue.isEmpty {
			diabeticLabString += "This number equals a 3 month average blood sugar of \(averageGlucoseView.stringValue) (the goal is less than 150)."
		}
		if !microalbuminView.stringValue.isEmpty {
			if !diabeticLabString.isEmpty {
				diabeticLabString += "\nUrine Microalbumin: \(microalbuminView.stringValue)"
			} else {
				diabeticLabString += "Urine Microalbumin: \(microalbuminView.stringValue)"
			}
		}
		if !diabeticLabString.isEmpty {
			diabeticLabString = diabeticLabString.prependSectionHeader("     Blood sugar average/Microalbumin")
		}
		
		return diabeticLabString
	}
	
	func generateCholesterolSection() -> String {
		var cholesterolLabString = String()
		if !totalCholesterolView.stringValue.isEmpty {
			cholesterolLabString += "Total Choldesterol: \(totalCholesterolView.stringValue).\nNormal is less than 200. Keep dietary cholesterol under 300mg per day and keep total fat in your diet to less than 30 percent of your total daily calorie intake.\n"
		}
		if !triglyceridesView.stringValue.isEmpty {
			cholesterolLabString += "Triglycerides (fat): \(triglyceridesView.stringValue).\nNormal is less than 150. Decrease the amount of fat in your diet to positively affect this number. \n"
		}
		if !hdlsView.stringValue.isEmpty {
			cholesterolLabString += "HDL Cholesterol: \(hdlsView.stringValue).\nNormal is above 40 and the goal is above 50.  This is the \"good\" cholesterol and protects against heart attacks.  Excercise will improve this number.\n"
		}
		if !ldlsView.stringValue.isEmpty {
			cholesterolLabString += "LDL Cholesterol: \(ldlsView.stringValue).\nFair is less than 130, good is less than 100, and excellent is less than 70. This is the \"bad\" cholesterol. Lifestyle changes such as diet and exercise can decrease this number."
		}
		if !ldlConcentrationView.stringValue.isEmpty {
			cholesterolLabString += "\nLDL Particle Concentration: \(ldlConcentrationView.stringValue)"
		}
		if !smallLDLView.stringValue.isEmpty {
			if !ldlConcentrationView.stringValue.isEmpty {
				cholesterolLabString += "    Small Dense LDL: \(smallLDLView.stringValue)"
			} else {
			cholesterolLabString += "\nSmall Dense LDL: \(smallLDLView.stringValue)"
			}
		}
		
		if !cholesterolLabString.isEmpty {
			cholesterolLabString = cholesterolLabString.prependSectionHeader("     Cholesterol")
		}
		
		return cholesterolLabString
	}
    
    @IBAction func showLabPrintView(_ sender: Any?) {
        processToClipboard(self)
        printLetterheadWithText(finalLabData, fontSize: 10.0)

    }

}

