//
//  ViewController.swift
//  eScripts
//
//  Created by Fool on 9/7/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class eScriptVC: NSViewController, NSOpenSavePanelDelegate {
    
    @IBOutlet var scriptScroll: NSScrollView!
    @IBOutlet weak var eScriptView: NSView!
    
    var fileLabelName = String()
    var patientName = String()
    var theText = String()
    var addPtName = String()
    
    weak var viewDataDelegate: webViewDataProtocol?
    
    var scriptText: NSTextView {
        get {
            return scriptScroll.contentView.documentView as! NSTextView
        }
    }
    
    var scriptData = eScript(theText: "")
    var ptChartData = ChartData(chartData: "", aptTime: "", aptDate: 0)
    
    var _undoManager = UndoManager()
    override var undoManager: UndoManager? {
        return _undoManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Until I figure out how to handle macOS Dark Mode
        //forcing the background of the scriptText view to stay white is a functional fix
        scriptText.backgroundColor = .white
        scriptText.font = NSFont.systemFont(ofSize: 16)
        processPFData(self)
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let theWindow = self.view.window {
            theWindow.title = "eScript"
            //This removes the ability to resize the window of a view
            //opened by a segue
            theWindow.styleMask.remove(.resizable)
            //This makes the window float at the front of the other windows
            theWindow.level = .floating
            theWindow.setFrameUsingName("eScriptWindow")
            theWindow.windowController!.windowFrameAutosaveName = "eScriptWindow"
        }
        
    }
    
    
    @IBAction func processPFData(_ sender: Any) {
        
        let eScriptHandler = {
            print("In the eScriptHandler of the processPFData function")
            //Get name and DOB
            self.fileLabelName = getFileLabellingName(self.scriptData.ptName)
            
            //Get script data
            
            let finalScriptData = self.scriptData.reportOutput()
            
            let processDate = Date()
            let processDateFormatter = DateFormatter()
            processDateFormatter.dateFormat = "MM/dd/yy"
            let processRequestDate = processDateFormatter.string(from: processDate)
            
            let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
            let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
            self.scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
            self.scriptText.string = "MEDICATION REFILL REQUEST - \(processRequestDate)\n\n\(self.scriptData.ptName)          DOB: \(self.scriptData.ptDOB) (\(self.scriptData.ptAge))\n\n\(self.scriptData.pharmacy)\n\(finalScriptData)\n\nRESPONSE:\n"
        }
        
        createeScriptObjectWithHandler(eScriptHandler)
        
    }
    
    @IBAction func saveFile(_ sender: Any) {
        guard let fileTextData = scriptText.string.data(using: String.Encoding.utf8) else { return }
        
        saveExportDialogWithData(fileTextData, andFileExtension: ".txt")
    }
    
    
    func saveExportDialogWithData(_ data: Data, andFileExtension ext: String) {
        //Get the visit date
        let requestDate = Date()
        let labelDateFormatter = DateFormatter()
        labelDateFormatter.dateFormat = "yyMMdd"
        let labelRequestDate = labelDateFormatter.string(from: requestDate)
        
        let savePath = NSHomeDirectory()
        let saveLocation = "\(FilePath.baseFolder.rawValue)/\(FilePath.scrapedScripts.rawValue)"
        
        let saveDialog = NSSavePanel()
        
        saveDialog.nameFieldStringValue = "\(fileLabelName) RXCOM \(labelRequestDate)"
        saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
        saveDialog.beginSheetModal(for: self.view.window!,completionHandler: {(result: NSApplication.ModalResponse) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let filePath = saveDialog.url {
                    if let path = URL(string: String(describing: filePath) + ext) {
                        do {
                            try data.write(to: path, options: .withoutOverwriting)
                            //This is where we can close the spawning window if the save is successful
                            self.closeTheWindow()
                        } catch {
                            MissingData().alertToMissingDataWithMessage(.existingFile, inWindow: self.view.window!)
                        }
                    }
                }
                
            }
        })
    }
    
    private func closeTheWindow() {
        //To close the window with the current design, I needed a specific outlet to the view so I could track back to it's window and tell it to close
        eScriptView.window!.close()
    }
    
    @IBAction func addVisitDates(_ sender: Any) {
        
        let visitDateHandler: () -> Void = {
            let theText = self.viewDataDelegate!.viewContent
            
            var lastAppointment:String {return getLastAptInfoFrom(theText)}
            var nextAppointment:String {return self.getNextAptInfoFrom(theText)}
            
            
            let currentResults = self.scriptText.string
            let finalScriptData = currentResults.replacingOccurrences(of: "\n\nRESPONSE:", with: "\n\nLast Apt: \(lastAppointment)\nNext Apt: \(nextAppointment)")
            
            let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
            let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
            self.scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
            self.scriptText.string = "\(finalScriptData)\n\nRESPONSE:\n"
            self.scriptText.didChangeText()
        }

        viewDataDelegate?.getWebViewValueByClassName("charts outlet", index: 0, completion: visitDateHandler)
    }
    
    @IBAction func addScript(_ sender: Any) {
        var namesMatch = true
        
        let newDemoHandler: () -> Void = {
            self.addPtName = self.viewDataDelegate!.viewContent
            print("New Script Pt Name:\n\n\(self.addPtName)")
            print("New name has been set to: \(self.addPtName)")
            let newNameComponents = Set(self.addPtName.lowercased().components(separatedBy: " "))
            let oldNameComponents = Set(self.scriptData.ptName.lowercased().components(separatedBy: " "))
            
            if !newNameComponents.isSubset(of: oldNameComponents) && !oldNameComponents.isSubset(of: newNameComponents) {
                //After notifying the user, break out of the program
                namesMatch = false
                let theAlert = NSAlert()
                theAlert.messageText = "The refill information you're trying to add is for \(self.addPtName) rather than \(self.scriptData.ptName)."
                theAlert.beginSheetModal(for: NSApplication.shared.mainWindow!) { (NSModalResponse) -> Void in
                    let returnCode = NSModalResponse
                    print(returnCode)
                }
                return
            }
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=patient-info-name", completion: newDemoHandler)
        
        
        if namesMatch == true {
        let addScriptHandler: () -> Void = {
            let currentResults = self.scriptText.string

            //Get script data
            var finalScriptData = "\n\n\(self.scriptData.pharmacy)\n\(self.scriptData.reportOutput())"

            finalScriptData = currentResults.replacingOccurrences(of: "\n\nRESPONSE:", with: finalScriptData)

            let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
            let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
            self.scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
            let count = Int(self.scriptText.string.count)
            self.scriptText.shouldChangeText(in: NSMakeRange(0, count), replacementString: "\(finalScriptData)\n\nRESPONSE:\n")
            self.scriptText.string = "\(finalScriptData)\n\nRESPONSE:\n"
            self.scriptText.didChangeText()
        }
        
        createeScriptObjectWithHandler(addScriptHandler)
    }
    }
 
 func registerUndoAddScript(_ previous:String) {
  undoManager?.prepare(withInvocationTarget: self.addScript(self))
  undoManager?.setActionName("Add Script")
 }
    
    private func getNextAptInfoFrom(_ theText: String) -> String {
        let nextAppointments = theText.findRegexMatchBetween("Appointments", and: "View all appointments")
        let activeEncounters = nextAppointments.ranges(of: "(?s)(\\w\\w\\w \\d\\d, \\d\\d\\d\\d)(.*?)(\\n)(?=\\w\\w\\w \\d\\d, \\d\\d\\d\\d)", options: .regularExpression).map{nextAppointments[$0]}.map{String($0)}.filter {$0.contains("Pending arrival")}
        if activeEncounters.count > 0 {
            return activeEncounters[0].simpleRegExMatch("\\w\\w\\w \\d\\d, \\d\\d\\d\\d - \\d\\d:\\d\\d \\w\\w")
        } else {
            return "Next apt not found"
        }
    }
 
 override var representedObject: Any? {
  didSet {
  // Update the view, if already loaded.
  }
 }
    

    private func createeScriptObjectWithHandler(_ handler: @escaping () -> Void) {
        print("Starting createeScriptObjectWithHandler function")
        
        let ptNameHandler: () -> Void = {
            self.scriptData.ptName = self.viewDataDelegate!.viewContent.capitalized
            print("ptNameHandler = \(self.scriptData.ptName)")
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=patient-info-name", completion: ptNameHandler)
        
        let ptDOBHandler: () -> Void = {
            self.scriptData.ptDOB = self.viewDataDelegate!.viewContent
            print("ptDOBHandler = \(self.scriptData.ptDOB)")
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=patient-info-dob", completion: ptDOBHandler)
        
        let scriptDateHandler: () -> Void = {
            self.scriptData.scriptDate = self.viewDataDelegate!.viewContent
            print("scriptDateHandler = \(self.scriptData.scriptDate)")
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=medication-prescribed-date", completion: scriptDateHandler)
        
        let scriptMedHandler: () -> Void = {
            self.scriptData.scriptMed = self.viewDataDelegate!.viewContent
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=dispensed-medication-name", completion: scriptMedHandler)
        
        let scriptSigHandler: () -> Void = {
            self.scriptData.scriptSig = self.viewDataDelegate!.viewContent
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=dispensed-sig", completion: scriptSigHandler)
        
        let scriptQtyHandler: () -> Void = {
            self.scriptData.scriptQty = self.viewDataDelegate!.viewContent
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=dispensed-quantity", completion: scriptQtyHandler)
        
        let scriptUnitHandler: () -> Void = {
            self.scriptData.scriptUnit = self.viewDataDelegate!.viewContent
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=dispensed-unit", completion: scriptUnitHandler)
        
        let daysSupplyHandler: () -> Void = {
            self.scriptData.daysSupply = self.viewDataDelegate!.viewContent
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=dispensed-days-supply", completion: daysSupplyHandler)
        
        let substitutionsHandler: () -> Void = {
            self.scriptData.substitutions = self.viewDataDelegate!.viewContent
        }
        self.viewDataDelegate?.getWebViewValueByQuerySelector("data-element=dispensed-substitutions", completion: substitutionsHandler)
        
        let pharmRefillsHandler: () -> Void = {
            self.scriptData.refills = simpleRegExMatch(self.viewDataDelegate!.viewContent, theExpression: "(?m)NUMBER OF REFILLS\\s+?.*\\s+?SUBSTITUTIONS").cleanTheTextOf(["NUMBER OF REFILLS", "SUBSTITUTIONS"]).removeWhiteSpace()
            self.scriptData.pharmacy = simpleRegExMatch(self.viewDataDelegate!.viewContent, theExpression: "(?m)NAME\\s+?.*\\s+?TELEPHONE NUMBER").cleanTheTextOf(["NAME", "TELEPHONE NUMBER"]).removeWhiteSpace()
            print("pharmRefillsHandler01 = \(self.scriptData.refills)")
            print("pharmRefillsHandler = \(self.scriptData.pharmacy)")
        }
        self.viewDataDelegate?.getWebViewValueByClassName("erx-change-detail ember-view", index: 0, completion: pharmRefillsHandler)
        
            let refillHandler: () -> Void = {
                print("In the refillHandler of the createeScriptObjectWithHandler function")
                self.scriptData.lastFillDate = simpleRegExMatch(self.viewDataDelegate!.viewContent, theExpression: "(?m)LAST FILL DATE\\s+?.*\\s+?ASSOCIATED DIAGNOSIS").cleanTheTextOf(["LAST FILL DATE", "ASSOCIATED DIAGNOSIS"]).removeWhiteSpace()
                self.scriptData.dx = simpleRegExMatch(self.viewDataDelegate!.viewContent, theExpression: "(?m)ASSOCIATED DIAGNOSIS\\s+?.*\\s+?NOTE TO PHARMACY").cleanTheTextOf(["ASSOCIATED DIAGNOSIS", "NOTE TO PHARMACY"]).removeWhiteSpace()
                handler()
            }

        self.viewDataDelegate?.getWebViewValueByClassName("detail-pane-body-wrapper ember-view rx-renewal__detail-pane-body", index: 0, completion: refillHandler)
    }
}

