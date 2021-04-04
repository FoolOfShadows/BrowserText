//
//  GeneralLetterVC.swift
//  BrowserText
//
//  Created by FoolOfShadows on 4/1/21.
//  Copyright © 2021 Fool. All rights reserved.
//

import Cocoa

class GeneralLetterVC: NSViewController {
    @IBOutlet weak var ptName: NSTextField!
    @IBOutlet weak var todaysDate: NSTextField!
    @IBOutlet var ltrBodyTextView: NSTextView!
    @IBOutlet weak var senderName: NSTextField!
    @IBOutlet weak var senderTitle: NSTextField!
    
    
    private let currentDate = Date()
    private let formatter = DateFormatter()
    
//    var labelDate:String {
//        formatter.dateFormat = "yyMMdd"
//        return formatter.string(from: currentDate)
//    }
    
    var currentPatient = PatientDataProfile()
    
    weak var letterDelegate: LetterDataProtocol?
    //weak var viewDataDelegate: webViewDataProtocol?
    
    override func viewDidLoad() {
        todaysDate.stringValue = currentDateLong()
        //print("Patients name is: \(currentPatient.fullName)")
        ptName.stringValue = currentPatient.fullName
        ltrBodyTextView.font = .systemFont(ofSize: 16)
    }
    
    @IBAction func printLetter(_ sender: Any) {
        let genLtrData = GeneralLetterData(ltrDate: todaysDate.stringValue, ptName: ptName.stringValue, address: currentPatient.fullAddress, ltrBody: ltrBodyTextView.string, senderName: senderName.stringValue, senderTitle: senderTitle.stringValue)
        let fileName = createFileLabelFrom(PatientName: currentPatient.labelName, FileType: "LTRT", date: String(Date().shortDate()))
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(fileName, forType: NSPasteboard.PasteboardType.string)
        
        printLetterheadWithRichText(genLtrData.generateOutput(), fontSize: 14.0, window: self.view.window!, andCloseWindow: true)
    }
    @IBAction func reinstatementOK(_ sender: Any) {
        ltrBodyTextView.string = DefaultLetters.reinOK.rawValue
    }
    @IBAction func reinstatmentDeclined(_ sender: Any) {
        ltrBodyTextView.string = DefaultLetters.reinNo.rawValue
    }
    @IBAction func tagReminder(_ sender: Any) {
        ltrBodyTextView.string = DefaultLetters.tagRmndr.rawValue
    }
    @IBAction func russSenderTitle(_ sender: Any) {
        senderName.stringValue = DefaultLetters.rwSender.rawValue
        senderTitle.stringValue = DefaultLetters.rwTitle.rawValue
    }
    @IBAction func drWhelchelSenderTitle(_ sender: Any) {
        senderName.stringValue = DefaultLetters.drWSender.rawValue
        senderTitle.stringValue = DefaultLetters.drWTitle.rawValue
    }
    @IBAction func donnaSenderTitle(_ sender: Any) {
        senderName.stringValue = DefaultLetters.dwSender.rawValue
        senderTitle.stringValue = DefaultLetters.dwTitle.rawValue
    }
    @IBAction func berthaSenderTitle(_ sender: Any) {
        senderName.stringValue = DefaultLetters.bcSender.rawValue
        senderTitle.stringValue = DefaultLetters.bcTitle.rawValue
    }
    
    enum DefaultLetters:String {
        case reinOK = """
        1
        """
        case reinNo = """
        2
        """
        case tagRmndr = """
        3
        """
        case rwSender = "russ whelchel"
        case rwTitle = "Administrator"
        case drWSender = "Dawn Whelchel, M.D."
        case drWTitle = ""
        case dwSender = "Donna Whelchel"
        case dwTitle = "Accounts Manager"
        case bcSender = "Bertha Cowart, M.A."
        case bcTitle = "Office Manager"
    }
    
}
