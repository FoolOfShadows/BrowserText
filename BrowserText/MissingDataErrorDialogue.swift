//
//  MissingDataErrorDialogue.swift
//  BrowserText
//
//  Created by Fool on 1/28/20.
//  Copyright © 2020 Fool. All rights reserved.
//

import Cocoa

struct MissingData {
    enum MissingDataErrorMessage:String {
        case correctBits = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
        case clickElipsis = "It looks like you haven't clicked the elipses to reveal the patients date of birth.  Give it another shot."
        case existingFile = "There is already a file with this name.\n Please choose a different name."
        case notICD10 = "It appears Practice Fusion is not set to show ICD-10 diagnoses codes.  Please set the Show by option in the Diagnoses section to ICD-10 and try again."
        case needProfileTab = "You need to be on the Profile tab in the patient's chart to run this process.  Please switch to the Profile tab and try again."
        case ssn = "SOCIAL SECURITY NUMBER"
    }
    

    func alertToMissingDataWithMessage(_ message: MissingDataErrorMessage, inWindow window:NSWindow) {
            //Create an alert to let the user know the clipboard doesn't contain
            //the correct PF data
            //After notifying the user, break out of the program
            let theAlert = NSAlert()
            theAlert.messageText = message.rawValue
            theAlert.beginSheetModal(for: window) { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print(returnCode)}
    }
}
