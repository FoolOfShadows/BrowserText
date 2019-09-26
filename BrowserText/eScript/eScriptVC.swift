//
//  ViewController.swift
//  eScripts
//
//  Created by Fool on 9/7/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

class eScriptVC: NSViewController, NSOpenSavePanelDelegate {

	//@IBOutlet var scriptText: NSTextView!
    @IBOutlet var scriptScroll: NSScrollView!
    @IBOutlet weak var eScriptView: NSView!
    
	var fileLabelName = String()
	var patientName = String()
    var theText = String()
    
    //var saveSuccessful = false
    
    weak var viewDataDelegate: webViewDataProtocol?
    
    var scriptText: NSTextView {
        get {
            return scriptScroll.contentView.documentView as! NSTextView
        }
    }
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
        //scriptUndoManager = scriptText.undoManager
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
		
		//Get the clipboard to process
//        let pasteBoard = NSPasteboard.general
//        let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text"))
		
		//Get name and DOB
		guard let ptNameAgeDOB = nameAgeDOB(theText) else { return }
		patientName = ptNameAgeDOB.0.capitalized
		let ptPharmacy = ptNameAgeDOB.1
		let pharmWithLocation = checkPharmacyLocationFrom(ptPharmacy)
		let ptDOB = ptNameAgeDOB.2
		fileLabelName = getFileLabellingName(patientName)
		//print(fileLabelName)
		
		//Get script data
		let finalScriptData = getScriptDataFrom(theText)
        
        let processDate = Date()
        let processDateFormatter = DateFormatter()
        processDateFormatter.dateFormat = "MM/dd/yy"
        let processRequestDate = processDateFormatter.string(from: processDate)
		
		let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
		let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
		scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
		scriptText.string = "MEDICATION REFILL REQUEST - \(processRequestDate)\n\n\(patientName)          DOB: \(ptDOB)\n\n\(pharmWithLocation)\n\(finalScriptData)\n\nRESPONSE:\n"
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
		let saveLocation = "WPCMSharedFiles/zBertha Review/01 The Script Corral"
        
        //var saveSuccessful = false
		
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
							let alert = NSAlert()
							alert.messageText = "There is already a file with this name.\n Please choose a different name."
							alert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
								let returnCode = NSModalResponse
								print(returnCode)
							}
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
            var nextAppointment:String {return getNextAptInfoFrom(theText)}
            
            let currentResults = self.scriptText.string
            let finalScriptData = currentResults.replacingOccurrences(of: "\n\nRESPONSE:", with: "\n\nLast Apt: \(lastAppointment)\nNext Apt: \(nextAppointment)")
            
            let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
            let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
            self.scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
            //let count = Int(scriptText.string.count)
            //scriptText.shouldChangeText(in: NSMakeRange(0, count), replacementString: "\(finalScriptData)\n\nRESPONSE:\n")
            self.scriptText.string = "\(finalScriptData)\n\nRESPONSE:\n"
            self.scriptText.didChangeText()
        }
        
        viewDataDelegate?.getWebViewDataByID("ember3", completion: visitDateHandler)
    }
	
    @IBAction func addScript(_ sender: Any) {
        
        let addScriptHandler: () -> Void = {
            let theText = self.viewDataDelegate!.viewContent
            
            let currentResults = self.scriptText.string
            
            guard let ptNameAgeDOB = nameAgeDOB(theText) else { return }
            /*if ptNameAgeDOB.0.capitalized != patientName*/
            let newNameComponents = Set(ptNameAgeDOB.0.capitalized.components(separatedBy: " "))
            let oldNameComponents = Set(self.patientName.components(separatedBy: " "))
            //print("New Set: \(newNameComponents)\nOldSet: \(oldNameComponents)\n\(newNameComponents.isSubset(of: oldNameComponents))\n\(oldNameComponents.isSubset(of: newNameComponents))")
            
            if !newNameComponents.isSubset(of: oldNameComponents) && !oldNameComponents.isSubset(of: newNameComponents) {
                //print("\(ptNameAgeDOB.0.capitalized) :: \(patientName)")
                //After notifying the user, break out of the program
                let theAlert = NSAlert()
                theAlert.messageText = "The refill information you're trying to add is for \(ptNameAgeDOB.0.capitalized) rather than \(self.patientName)."
                theAlert.beginSheetModal(for: NSApplication.shared.mainWindow!) { (NSModalResponse) -> Void in
                    let returnCode = NSModalResponse
                    print(returnCode)
                }
                return
            }
            
            //Get script data
            var finalScriptData = "\n\n\(ptNameAgeDOB.1)\n\(getScriptDataFrom(theText))"
            //print(finalScriptData)
            
            finalScriptData = currentResults.replacingOccurrences(of: "\n\nRESPONSE:", with: finalScriptData)
            
            let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
            let fontAttributes = NSDictionary(object: theUserFont, forKey: NSAttributedString.Key.font as NSCopying)
            self.scriptText.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
            let count = Int(self.scriptText.string.count)
            self.scriptText.shouldChangeText(in: NSMakeRange(0, count), replacementString: "\(finalScriptData)\n\nRESPONSE:\n")
            self.scriptText.string = "\(finalScriptData)\n\nRESPONSE:\n"
            self.scriptText.didChangeText()
        }
        
        viewDataDelegate?.getWebViewDataByID("ember3", completion: addScriptHandler)
        
    }
	
	func registerUndoAddScript(_ previous:String) {
		undoManager?.prepare(withInvocationTarget: self.addScript(self))
		undoManager?.setActionName("Add Script")
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

