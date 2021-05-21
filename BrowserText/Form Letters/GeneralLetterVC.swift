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
        senderName.stringValue = DefaultLetters.rwSender.rawValue
        senderTitle.stringValue = DefaultLetters.rwTitle.rawValue
    }
    @IBAction func reinstatmentDeclined(_ sender: Any) {
        ltrBodyTextView.string = DefaultLetters.reinNo.rawValue
        senderName.stringValue = DefaultLetters.rwSender.rawValue
        senderTitle.stringValue = DefaultLetters.rwTitle.rawValue
    }
    @IBAction func tagReminder(_ sender: Any) {
        ltrBodyTextView.string = DefaultLetters.tagRmndr.rawValue
    }
    @IBAction func unableToAccept(_ sender: Any) {
        ltrBodyTextView.string = DefaultLetters.unableToAccept.rawValue
        senderName.stringValue = DefaultLetters.rwSender.rawValue
        senderTitle.stringValue = DefaultLetters.rwTitle.rawValue
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
        We appreciate your recent payment and are glad to be able to reinstate you as a patient of Whelchel Primary Care Medicine.
            
        If in the future you find yourself unable to meet your financial obligations to us in a prompt manner, please contact our billing office at (903) 935-7101 extension 3 as soon as possible.  If it is determined at any point going forward that your account is more than 45 days past due and payment arrangements with our billing office have not been made or kept, we may withdraw our professional services with no further notice.  Note that any payment arrangements you may have made with our office prior to being dismissed are no longer in effect.
            
        Because any existing appointments you had with our office have been cancelled, you will need to call us at (903) 935-7101 to schedule a new appointment.
            
        We appreciate you working with us to resolve this issue and look forward to continuing to provide for your health care needs.
        """
        case reinNo = """
        While we appreciate your interest in re-establishing Whelchel Primary Care Medicine as your health care provider, we do not consider such an action to be prudent and therefore must decline.  If you have not yet found another health care provider we encourage you to do so as soon as possible.
        
        Thank you for your consideration,
        """
        case tagRmndr = """
        According to our records it is time for a follow up appointment with Dr. Dawn Whelchel.
        
        The nature of some medications used in your treatment make it important to keep regularly scheduled appointments to insure effectiveness, reduce possible risks, and avoid compliance related prescription delays.
        
        Please call our office at (903) 935-7101 to schedule an appointment at your earliest convenience.
        """
        case unableToAccept = """
        While we appreciate your interest in establishing Whelchel Primary Care Medicine as your health care provider, we will be unable to accept you as a patient of our practice at this time, and you will need to have your health care needs met by one of the other providers in the area.
            
        Thank you for your consideration,
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
