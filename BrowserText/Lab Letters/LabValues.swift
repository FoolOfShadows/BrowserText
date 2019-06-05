//
//  LabValues.swift
//  Lab Letter 3
//
//  Created by Fool on 10/26/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Foundation

enum LabValue: String {
	case low = " - Low"
	case normal = " - Normal"
	case borderline = " - Borderline High"
	case high = " - High"
	case underactive = " - Underactive"
	case overactive = " - Overactive"
}

enum LabIDs:String {
	case WBC
	case HEMATOCRIT
	case HEMOGLOBIN
	case PLATELETCOUNT = "PLATELET COUNT"
	case GLUCOSE
	case CREATININE
	case eGFRAA = "eGFR AFRICAN AMER."
	case eGFRNonAA = "eGFR NON-AFRICAN AMER."
	case POTASSIUM
	case CALCIUM
	case PROTEIN = "PROTEIN, TOTAL"
	case ALBUMIN
	case GLOBULIN = "CALC GLOBULIN"
	case AGRATIO = "CALC A/G RATIO"
	case BILIRUBIN = "BILIRUBIN, TOTAL"
	case ALKPHOS = "ALKALINE PHOSPHATASE"
	case AST
	case ALT
	case HBA1C = "HEMOGLOBIN A1c"
	case AVEGLUCOSE = "ESTIMATED AVERAGE GLUCOSE"
	case MICROALB1 = "DRL CALC MICALB/CR RNDM"
	case MICROALB2 = "CALC MICROALB/CREAT RND"
	case CHOLESTEROL
	case TRIGLYCERIDES
	case HDL = "HDL CHOLESTEROL"
	case LDL = "CALC LDL CHOL"
	case LDLCONC = "LDL PARTICLE (P) CONC"
	case SMALLLDL = "SMALL LDL-P"
	case TSH = "TSH, THIRD GENERATION"
	case FREET3 = "FREE T3"
	case FREET4 = "FREE T4 (THYROXINE)"
	case CK = "CK, TOTAL"
	case SEDRATE = "SEDIMENTATION RATE"
	case CREACTIVE = "C-REACTIVE PROTEIN"
	case CORTISOL = "CORTISOL, RANDOM"
	case VITAMINB12 = "VITAMIN B-12"
	case VITAMIND = "VITAMIN D, 25 OH"
	case IRON = "IRON, SERUM"
	case PSA1 = "DRL PSA, TOTAL"
	case PSA2 = "DRL PSA TOTAL, MC SCRN"
    case PSA3 = "PSA, TOTAL"
	case URICACID = "URIC ACID"
	case FOLICACID = "FOLIC ACID"
	case FERRITIN
	case MAGNESIUM
	case LDH
	case LIPASE
	case AMYLASE
	case RHEUMATOID = "RHEUMATOID FACTOR, QUANT"
	case RETICULOCYTE
	case ANA = "Anti-Nuclear Antibodies"
	case HPYLORI = "H. PYLORI"
//	case HPYLORI1 = "H. PYLORI IgG"
//	case HPYLORI2 = "H. PYLORI AG, STOOL"
	case INR
	case TESTOSTERONE
	case OTHER
	
	var outputTitle: String {
		switch self {
		case .WBC: return "White Blood Count: "
		case .HEMATOCRIT: return "Hematocrit: "
		case .HEMOGLOBIN: return "Hemoglobin: "
		case .PLATELETCOUNT: return "Platelets: "
		case .GLUCOSE: return "Glucose: "
		case .CREATININE: return "Creatinine: "
		case .eGFRAA: return "eGFR African-Amer: "
		case .eGFRNonAA: return "eGFR Non-African-Amer: "
		case .POTASSIUM: return "Potassium:"
		case .CALCIUM: return "Calcium: "
		case .PROTEIN: return "Protein: "
		case .ALBUMIN: return "Albumin: "
		case .GLOBULIN: return "Globulin: "
		case .AGRATIO: return "A/G Ratio: "
		case .BILIRUBIN: return "Bilirubin: "
		case .ALKPHOS: return "Alk Phosphatase: "
		case .AST: return "SGOT (AST): "
		case .ALT: return "SGPT (ALT): "
		case .HBA1C: return "ESTIMATED AVERAGE GLUCOSE "
		case .AVEGLUCOSE: return ""
		case .MICROALB1: return "Urine Microalbumin: "
		case .MICROALB2: return "Urine Microalbumin: "
		case .CHOLESTEROL: return ""
		case .TRIGLYCERIDES: return ""
		case .HDL: return ""
		case .LDL: return ""
		case .LDLCONC: return "LDL Particle Concentration: "
		case .SMALLLDL: return "Small Dense LDL: "
		case .TSH: return "TSH: "
		case .FREET3: return "Free T3: "
		case .FREET4: return "Free T4: "
		case .CK: return "Creatinine Kinase: "
		case .SEDRATE: return "Sedimentation Rate: "
		case .CREACTIVE: return "C-Reactive Protein: "
		case .CORTISOL: return "Cortisol: "
		case .VITAMINB12: return "Vitamin B12: "
		case .VITAMIND: return "Vitamin D: "
		case .IRON: return "Iron: "
		case .PSA1, .PSA2, .PSA3: return "PSA: "
//        case .PSA2: return "PSA: "
//        case .PSA3: return "PSA: "
		case .URICACID: return "Uric Acid: "
		case .FOLICACID: return "Folic Acid: "
		case .FERRITIN: return "Ferritin: "
		case .MAGNESIUM: return "Magnesium: "
		case .LDH: return "LDH: "
		case .LIPASE: return "Lipase: "
		case .AMYLASE: return "Amylase: "
		case .RHEUMATOID: return "Rheumatoid Factor: "
		case .RETICULOCYTE: return "Reticulocyte Count: "
		case .ANA: return "Anti-Nuclear Antibodies: "
		case .HPYLORI: return "H. Pylori: "
//		case .HPYLORI1: return "H. Pylori: "
//		case .HPYLORI2: return "H. Pylori: "
		case .INR: return "INR: "
		case .TESTOSTERONE: return "Testosterone: "
		case .OTHER: return ""
		}
	}
}

enum LabTitles:String {
	case wbc = "White Blood Count:"
	case hct = "Hematocrit:"
	case hgb = "Hemoglobin:"
	case platelets = "Platelets:"
	case glucose = "Glucose:"
	case creatinine = "Creatinine:"
	case egfraa = "eGFR African-Amer:"
	case egfrnonaa = "eGFR Non-AFrican-Amer:"
	case potassium = "Potassium:"
	case calcuim = "\nCalcium:" //I don't like the way this is set up
	case protein = "Protein:"
	case albumin = "Albumin:"
	case globulin = "Globulin:"
	case agratio = "A/G Ratio:"
	case bilirubin = "Bilirubin:"
	case alkphos = "Alk Phosphatase:"
	case ast = "SGOT (AST):"
	case alt = "SGPT (ALT):"
	case hgba1c = "ESTIMATED AVERAGE GLUCOSE"
	case microalb = "Urine Microalbumin:"
	case ldlconc = "LDL Particle Concentration:"
	case smallldl = "Small Dense LDL:"
	case tsh = "TSH:"
	case freet3 = "Free T3:"
	case freet4 = "Free T4:"
	case ck = "Creatinine Kinase:"
	case sedrate = "Sedimentation Rate:"
	case creactive = "C-Reactive Protein:"
	case cortisol = "Cortisol:"
	case b12 = "Vitamin B12:"
	case vitamind = "Vitamin D:"
	case iron = "Iron:"
	case psa = "PSA:"
	case uricacid = "Uric Acid:"
	case folicacid = "Folic Acid:"
	case ferritin = "Ferritin:"
	case magnesium = "Magnesium:"
	case ldh = "LDH:"
	case lipase = "Lipase:"
	case amylase = "Amylase:"
	case rheumatoid = "Rheumatoid Factor:"
	case reticulocyte = "Reticulocyte Count:"
	case ana = "Anti-Nuclear Antibodies:"
	case hpylori = "H.Pylori:"
	case inr = "INR:"
	case testosterone = "Testosterone:"
}


struct LabValues {
	let wbcValues = (lowF:4.0,
	                 highF:11.0,
	                 lowM:4.0,
	                 highM:11.0)
	
	let hgbValues = (lowF:11.5,
	                 highF:15.5,
	                 lowM:13.0,
	                 highM:17.0)
	
	let hctValues = (lowF:34.0,
	                 highF:45.0,
	                 lowM:37.0,
	                 highM:49.0)
	
	let plateletsValues = (lowF:130.0,
	                       highF:400.0,
	                       lowM:130.0,
	                       highM:400.0)
	
	let eGFRAAValues = (lowF:60.1,
	                    highF:1000.0,
	                    lowM:60.1,
	                    highM:1000.0)
	
	let eGFRNonAAValues = (lowF:60.1,
	                       highF:1000.0,
	                       lowM:60.1,
	                       highM:1000.0)
	
	let creatinineValues = (lowF:0.6,
	                        highF:1.3,
	                        lowM:0.8,
	                        highM:1.4)
	//Updated for male ranges 5/28/17 per CPL
	//Females 6/26/17
	let potassiumValues = (lowF:3.5,
	                       highF:5.4,
	                       lowM:3.5,
	                       highM:5.4)
	
	let calciumValues = (lowF:8.5,
	                     highF:10.5,
	                     lowM:8.5,
	                     highM:10.5)
	
	//Protein ranges updated as of 8/29/16 per CPL
	let proteinValues = (lowF:6.1,
	                     highF:8.3,
	                     lowM:6.1,
	                     highM:8.3)
	
	//Updated for female ranges 5/28/17 per CPL
	//Updated for male ranges 6/11/17 per CPL
	let albuminValues = (lowF:3.5,
	                     highF:5.2,
	                     lowM:3.5,
	                     highM:5.2)
	
	//Male values updated 7/22/17 per CPL
	let globValues = (lowF:2.0,
	                  highF:3.8,
	                  lowM:1.9,
	                  highM:3.7)
	
	//Calc A/G Ratio ranges updated as of 9/7/16 per CPL
	let agRatioValues = (lowF:1.0,
	                     highF:2.6,
	                     lowM:1.0,
	                     highM:2.6)
	
	//Values for female update per CPL 6/4/17 again 7/30/17
	let biliValues = (lowF:0.1,
	                  highF:1.3,
	                  lowM:0.1,
	                  highM:1.3)
	
	//Alkaline Phosphatase ranges for men updated as of 6/6/17 per CPL
	//female updated 5/9/17 and again 6/18/17
	let alkPhosValues = (lowF:30.0,
	                     highF:132.0,
	                     lowM:30.0,
	                     highM:132.0)
	
	//AST ranges updated as of 8/29/16 per CPL
	//Male values updated 6/18/17 per CPL
	let astValues = (lowF:9.0,
	                 highF:40.0,
	                 lowM:9.0,
	                 highM:50.0)
	
	//Protein ranges updated as of 8/29/16 per CPL
	let altValues = (lowF:5.0,
	                 highF:40.0,
	                 lowM:5.0,
	                 highM:50.0)
	
	let ldlConcValues = (lowF:0.0,
	                     highF:1000.0,
	                     lowM:0.0,
	                     highM:1000.0)
	
	let smallLDLValues = (lowF:0.0,
	                      highF:528.0,
	                      lowM:0.0,
	                      highM:528.0)
	
	let psaValues = (lowF:-0.1,
	                 highF:0.1,
	                 lowM:0.0,
	                 highM:4.0)
	
	//Updated ranges for male values 5/28/17 per CPL
	let ironValues = (lowF:35.0,
	                  highF:145.0,
	                  lowM:59.0,
	                  highM:158.0)
	
	//Updated ranges for male values 6/11/17 per CPL
	let microAlbValues = (lowF:0.0,
	                      highF:20.0,
	                      lowM:0.0,
	                      highM:20.0)
	
	//Male values updated 7/22/17 per CPL
	let tshValues = (lowF:0.3,
	                 highF:4.2,
	                 lowM:0.4,
	                 highM:4.1)
	
	//Free T3 ranges for women updated 5/7/17 as found on lab results from CPL. Again on 7/2/17
	//Values for men updated 6/4/17 per CPL
	let freeT3Values = (lowF:2.2,
	                    highF:4.2,
	                    lowM:2.4,
	                    highM:4.2)
	
	//Free T4 ranges for men updated 5/7/17 as found on lab results from CPL
	//values for women updated 8/5/17 per CPL
	let freeT4Values = (lowF:0.80,
	                    highF:1.90,
	                    lowM:0.80,
	                    highM:1.90)
	
	//Female values updated 6/4/17 per CPL
	//Male values updated 7/22/17 per CPL
	let ckValues = (lowF:20.0,
	                highF:180.0,
	                lowM:20.0,
	                highM:200.0)
	
	//Female values updated 6/11/17 per CPL, and again 6/26/17
	let sedValues = (lowF:0.0,
	                 highF:30.0,
	                 lowM:0.0,
	                 highM:20.0)
	
	let cReactiveValues = (lowF:0.0,
	                       highF:0.5,
	                       lowM:0.0,
	                       highM:0.8)
	
	//Male values updated 6/11/17 per CPL
	//Female values updated 6/11/17 per CPL
	let cortisolValues = (lowF:4.8,
	                      highF:19.5,
	                      lowM:4.8,
	                      highM:19.5)
	
	//Female values updated 6/18/17 per CPL
	let b12Values = (lowF:200.0,
	                 highF:950.0,
	                 lowM:243.0,
	                 highM:894.0)
	
	let dValues = (lowF:30.0,
	               highF:100.0,
	               lowM:30.0,
	               highM:100.0)
	
	//Updated values per CPL 6/4/17
	let glucoseValues = (low:70.0,
	                     borderline:101.0,
	                     high:105.0)
	
	//Updated values for females per CPL 5/17/17
	//Updated values for males per CPL 6/4/17
	let uricAcidValues = (lowF:2.4,
	                      highF:5.7,
	                      lowM:3.4,
	                      highM:7.0)
	
	//Female values updated 6/11/17 per CPL
	//Male updated 7/30/17 per CPL
	let ferritinValues = (lowF:13.0,
	                      highF:200.0,
	                      lowM:30.0,
	                      highM:400.0)
	
	let amylaseValues = (lowF:28.0,
	                     highF:100.0,
	                     lowM:28.0,
	                     highM:100.0)
	
	//Male and female values update 7/22/17 per CPL
	let lipaseValues = (lowF:13.0,
	                    highF:60.0,
	                    lowM:13.0,
	                    highM:60.0)
	
	let testosteroneValues = (lowF:6.0,
	                          highF:50.0,
	                          lowM:300.0,
	                          highM:720.0)
	
	let magnesiumValues = (lowF:1.6,
	                       highF:2.6,
	                       lowM:1.6,
	                       highM:2.6)
	
	//Female values updated 6/11/17 per CPL
	let folicAcidValues = (lowF:4.0,
	                       highF:1000.0,
	                       lowM:5.0,
	                       highM:1000.0)
	
	let ldhValues = (lowF:135.0,
	                 highF:214.0,
	                 lowM:135.0,
	                 highM:225.0)
	
	let reticulocyteValues = (lowF:0.5,
	                          highF:2.3,
	                          lowM:0.5,
	                          highM:2.3)
	
	let rheumatoidFactorValues = (lowF:0.0,
	                              highF:14.0,
	                              lowM:0.0,
	                              highM:14.0)
}


enum PatientGender:String {
	case F
	case M
}





struct StringValues {
	let tab = "    "
	let extraPhrases = ["CORTISOL, RANDOM Show test details",
                        "TSH, THIRD GENERATION Show test details",
	                    "DRL MICROALBUMIN/CREATININE, RANDOM Show test details",
	                    "MICROALBUMIN/CREATININE, RANDOM AND RATIO Show test details",
	                    "C-REACTIVE PROTEIN Show test details",
	                    "CK, TOTAL Show test details",
	                    "VITAMIN B-12 Show test details",
	                    "TSH Show test details",
	                    "adult patients with a TSH value between",
	                    "RHEUMATOID FACTOR,QUANT Show test details",
	                    "SEDIMENTATION RATE Show test details",
	                    "FREE T3 Show test details",
	                    "FREE T4 Show test details",
	                    "FREE T4 (THYROXINE) Show test details",
	                    "TSH Show test details",
	                    "VITAMIN D, 25 OH Show test details",
	                    "HEMOGLOBIN A1c W/EAG AND INT CHART Show test details",
	                    "ML/MIN/1.73",
	                    "mL/min/1.73",
	                    "HGB A1C                     ESTIMATED AVERAGE GLUCOSE",
	                    "HEMOGLOBINOPATHIES",
	                    "PSA, TOTAL, MEDICARE SCREEN",
	                    "DRL PSA TOTAL, MC SCRN Show test details",
	                    "PSA, TOTAL Show test details",
	                    "AMYLASE Show test details",
	                    "LIPASE Show test details",
	                    "GASTRIN Show test details",
	                    "FOLLICLE STIM HORMONE Show test details",
	                    "(HEMATOCRIT %)",
	                    "UNABLE TO CALCULATE A VALID LDL CHOLESTEROL WHEN THE TRIGLYCERIDE",
	                    "CREATININE, URINE, CONC.",
	                    "GLUCOSE\nNEGATIVE",
	                    "URIC ACID Show text details",
	                    "RHEUMATOID FACTOR, QUANT Show test details",
	                    "H. PYLORI IgG, QUAL Show test details",
	                    "H. PYLORI AG, STOOL Show test details",
	                    "CALCIUM, IONIZED",
	                    "TESTOSTERONE, FREE/TOTAL",
	                    "TESTOSTERONE REF RANGE",
	                    "URIC ACID Show test details",
	                    "DRL PSA, TOTAL Show test details",
	                    "FERRITIN Show test details",
	                    "FOLIC ACID Show test details",
	                    "LDH Show test details",
	                    "RETICULOCYTE COUNT Show test details",
	                    "MAGNESIUM Show test details",
	                    "CREATININE, RANDOM URINE Show test details",
	                    "TESTOSTERONE Show test details"]
	
	let moreExtraPhrases = ["HEMOGLOBIN A1c"]
}
