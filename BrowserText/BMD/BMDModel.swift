//
//  BMDModel.swift
//  Form Letters
//
//  Created by Fool on 11/15/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Foundation
import Cocoa

struct BMDData {
    enum BMDDx:String {
        case normal
        case osteopenia
        case osteoporosis
    }
    var ptName:String
    var ltrDate:String
    var testDate:String
    var tScore:Double
    var location:String
    var diagnosis:String { return getDxFromTScore(tScore)}
    var address:String
    var sigImage:NSImage {
        let sigURL = URL(fileURLWithPath: "\(NSHomeDirectory())/WPCMSharedFiles/WPCM Software Bits/00 CAUTION - Data Files/DawnSig1.png")
        return NSImage(byReferencing: sigURL)
    }
    var sigString:NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = sigImage
        return NSAttributedString(attachment: imageAttachment)
    }
    
    
    func getDxFromTScore(_ score: Double) -> String {
        switch score {
        case -1.0...10.0:
            return BMDDx.normal.rawValue
        case (-2.5)..<(-1.0):
            return BMDDx.osteopenia.rawValue
        case (-5.0)..<(-2.5):
            return BMDDx.osteoporosis.rawValue
        default:
            return "No score given, or score out of range."
        }
    }
    
    func generateOutput() -> NSAttributedString {
        //Set up a dictionary of font attributes for setting the final string to
        let font = NSFont(name: "Times New Roman", size: 14)
        let stringAttributes: [NSAttributedString.Key: Any] = [
            .font:font!
        ]
        
        //Instatiate the foundational string to be built upon
        let baseString = NSMutableAttributedString()
//        let header = """
//
//\(ltrDate)
//
//
//\(ptName)
//\(address)
//
//
//
//Dear \(ptName),
//
//"""
        let header = NSAttributedString(string: "\n\n\(ltrDate)\n\n\n\(ptName)\n\(address)\n\n\nDear \(ptName),\n\n")
//        let maintainDensity = """
//To continue preserving your bone mass and strength I recommend weight bearing exercises and a calcium supplement such as Citrical, Caltrate, etc. in the amount of 500 mg or 600 mg of calcium once a day and Vitamin D3, 1,000 IU daily.
//
//If you have any further questions regarding the results of this test, please call my office to make an appointment to discuss them.
//
//Sincerely,
//\(sigAttachment)
//Dawn R. Whelchel, M.D.
//"""
        let maintainDensity = NSAttributedString(string: "To continue preserving your bone mass and strength I recommend weight bearing exercises and a calcium supplement such as Citrical, Caltrate, etc. in the amount of 500 mg or 600 mg of calcium once a day and Vitamin D3, 1,000 IU daily.\n\nIf you have any further questions regarding the results of this test, please call my office to make an appointment to discuss them.\n\nSincerely,\n")
//        let increaseDensity = """
//To increase your bone mass and strength and reduce fracture risk I recommend weight bearing exercises and a calcium supplement such as Citrical, Caltrate, etc. in the amount of 500 mg or 600 mg once or twice a day.  Vitamin D has also been shown to decrease falls, improve strength and decrease fracture risk by 20%.  I suggest Vitamin D3, 1,000 to 2,000 IU daily.
//
//We can discuss prescription treatment options at your next appointment to decide which is best for you.  Please call for an appointment if you do not already have one scheduled.
//Sincerely,
//\(sigAttachment)
//Dawn R. Whelchel, M.D.
//"""
        let increastDensity = NSAttributedString(string: "To increase your bone mass and strength and reduce fracture risk I recommend weight bearing exercises and a calcium supplement such as Citrical, Caltrate, etc. in the amount of 500 mg or 600 mg once or twice a day.  Vitamin D has also been shown to decrease falls, improve strength and decrease fracture risk by 20%.  I suggest Vitamin D3, 1,000 to 2,000 IU daily.\n\nWe can discuss prescription treatment options at your next appointment to decide which is best for you.  Please call for an appointment if you do not already have one scheduled.\n\nSincerely,\n")
        let signature = NSAttributedString(string: "\nDawn R. Whelchel, M.D.")
        
        switch diagnosis {
        case BMDDx.normal.rawValue:
//            return NSAttributedString(string:
//            """
//            \(header)
//            The Bone Mineral Density test performed on \(testDate) showed that you have a T-score of \(tScore) at the \(location) which corresponds to a diagnosis of NORMAL BONE DENSITY (you have no significant increased risk of fracture).
//
//            \(maintainDensity)
//            """
//            )
            let normalResults = NSAttributedString(string: "The Bone Mineral Density test performed on \(testDate) showed that you have a T-score of \(tScore) at the \(location) which corresponds to a diagnosis of NORMAL BONE DENSITY (you have no significant increased risk of fracture).\n\n")
            
            baseString.append(header)
            baseString.append(normalResults)
            baseString.append(maintainDensity)
            baseString.append(sigString)
            baseString.append(signature)
            baseString.addAttributes(stringAttributes, range: NSRange(location: 0, length: baseString.string.count))
            return baseString
        case BMDDx.osteopenia.rawValue:
//            return NSAttributedString(string:
//            """
//            \(header)
//            The Bone Mineral Density test performed on \(testDate) showed that you have a T-score of \(tScore) at the \(location) which corresponds to a diagnosis of OSTEOPENIA (bone mass is 15 to 25 percent below normal. You have about a 3 to 7 times greater risk of fracture).
//
//            Having osteopenia means you are at increased risk for hip fractures and spinal compression fractures. Hip fractures can be as serious as a stroke because of decreased mobility.
//
//            \(increaseDensity)
//            """
//            )
            let osteopeniaResults = NSAttributedString(string: "The Bone Mineral Density test performed on \(testDate) showed that you have a T-score of \(tScore) at the \(location) which corresponds to a diagnosis of OSTEOPENIA (bone mass is 15 to 25 percent below normal. You have about a 3 to 7 times greater risk of fracture).\n\nHaving osteopenia means you are at increased risk for hip fractures and spinal compression fractures. Hip fractures can be as serious as a stroke because of decreased mobility.")
            
            baseString.append(header)
            baseString.append(osteopeniaResults)
            baseString.append(increastDensity)
            baseString.append(sigString)
            baseString.append(signature)
            baseString.addAttributes(stringAttributes, range: NSRange(location: 0, length: baseString.string.count))
            return baseString
        case BMDDx.osteoporosis.rawValue:
//            return NSAttributedString(string:
//            """
//            \(header)
//            The Bone Mineral Density test performed on \(testDate) showed that you have a T-score of \(tScore) at the \(location) which corresponds to a diagnosis of OSTEOPOROSIS (bone mass is more than 25 percent below normal. You have about an 8 to 11 times greater risk of fracture).
//
//            Having osteoporosis means you are at increased risk for hip fractures and spinal compression fractures. Hip fractures can be as serious as a stroke because of decreased mobility.
//
//            \(increaseDensity)
//            """
//            )
            let osteoporosisResult = NSAttributedString(string: "The Bone Mineral Density test performed on \(testDate) showed that you have a T-score of \(tScore) at the \(location) which corresponds to a diagnosis of OSTEOPOROSIS (bone mass is more than 25 percent below normal. You have about an 8 to 11 times greater risk of fracture).\n\nHaving osteoporosis means you are at increased risk for hip fractures and spinal compression fractures. Hip fractures can be as serious as a stroke because of decreased mobility.")
            
            baseString.append(header)
            baseString.append(osteoporosisResult)
            baseString.append(increastDensity)
            baseString.append(sigString)
            baseString.append(signature)
            baseString.addAttributes(stringAttributes, range: NSRange(location: 0, length: baseString.string.count))
            return baseString
        default:
            //return NSAttributedString(string: "Failed to generate proper output.")
            let fail = NSAttributedString(string: "Failed to generate proper output.")
            baseString.append(fail)
            return baseString
        }
    }
    
}
