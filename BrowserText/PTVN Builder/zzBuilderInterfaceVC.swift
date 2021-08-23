//
//  BuilderInterfaceVC.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa
import Quartz

protocol ptvnDelegate: class {
    var currentData:ChartData { get set }
    var saveLocation:String { get set }
    var ptVisitDate:Int { get }
    var visitTime:String { get }
}

class zzBuilderInterfaceVC: NSViewController, ptvnDelegate {

    @IBOutlet weak var visitTimeView: NSTextField!
    @IBOutlet weak var visitDayView: NSPopUpButton!
    
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var currentData:ChartData = ChartData(chartData: "", aptTime: "", aptDate: 0)
    var visitTime = "00"
    
    //weak var showWindowDelegate: ShowMainWindowDelegate?
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("currentData inside Builder Module:\n\(currentData)")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        //This is where and how to give the window of a view
        //opened by a segue a title
        self.view.window?.title = "PTVN Builder"
        //This removes the ability to resize the window of a view
        //opened by a segue
        self.view.window?.styleMask.remove(.resizable)
    }
    
    func processInitialData() {
        //Get the clipboard to process
        let pasteBoard = NSPasteboard.general
        
        //FIXME: Does this need actual error handling?
        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        
        //Make sure the clipboard contents are from PF, otherwise notify the user
        if !theText.contains("Flowsheets") {
            //Create an alert to let the user know the clipboard doesn't contain
            //the correct PF data
            //After notifying the user, break out of the program
            let theAlert = NSAlert()
            theAlert.messageText = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print(returnCode)}
        }
        
        //Make sure the diagnosis are set to ICD-10 format - Don't need this anymore
//        if !theText.contains("ICD-10") {
//            //Create an alert to let the user know the diagnoses are not set to ICD10
//            print("Not set to ICD10")
//            //After notifying the user, break out of the program
//            let theAlert = NSAlert()
//            theAlert.messageText = "It appears Practice Fusion is not set to show ICD-10 diagnoses codes.  Please set the Show by option in the Diagnoses section to ICD-10 and try again."
//            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
//                _ = NSModalResponse
//            }
//        }
        
        //Create a ChartData struct with the clipboard data
        currentData = ChartData(chartData: theText, aptTime: visitTimeView.stringValue, aptDate: visitDayView.indexOfSelectedItem)
        
        //Get the info from the date scheduled popup menu
        ptVisitDate = visitDayView.indexOfSelectedItem
        //print("Day index selected: \(ptVisitDate)")
        
        //Set the files save location based on the users selection
        //var saveLocation = "Desktop"
        switch ptVisitDate {
        case 0:
            saveLocation = "Sync/WPCMSharedFiles/zDoctor Review/06 Dummy Files"
        case 1...4:
            saveLocation = "Sync/WPCMSharedFiles/zruss Review/Tomorrows Files"
        default:
            saveLocation = "Desktop"
        }
        
        visitTime = visitTimeView.stringValue
        
//        //Search for PTVN from last visit
//        //Set the search directory to the PTVN folder
//        let originFolderURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Sync/WPCMSharedFiles/zDonna Review/01 PTVN Files")
//        //Search for files with the same visit date
//        let ptvnList = originFolderURL.getFilesInDirectoryWhereNameContains(["\(currentData.lastAppointment)"])
//        //Create a the smallest likely unique version of the pt name
//        //to search with
//        let filterName = getFileLabellingNameFrom(currentData.ptName, ofType: FileLabelType.firstLast)
//        //Use that search name to filter the PTVNs whose date matched
//        let shortList = ptvnList.filter { $0.absoluteString.removingPercentEncoding!.contains(filterName) }
//        //Create an OldNoteData object from the text of the matching file
//        //and pull out just the charge information to be inserted into
//        //the saved file
//        var lastCharge = "Last PTVN not found."
//        var pharmacy = String()
//        if shortList.count > 0 {
//            lastCharge = OldNoteData(fileURL: shortList[0]).oldAssessment
//            pharmacy = OldNoteData(fileURL: shortList[0]).pharmacy
//        }
        
    }

    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNoteMeds" {
            if let toViewController = segue.destinationController as? BuilderInterfaceVC {
                processInitialData()
                toViewController.currentPTVNDelegate = self
                toViewController.currentData = currentData
                //toViewController.ptVisitDate = ptVisitDate
                toViewController.saveLocation = saveLocation
                //toViewController.visitTime = visitTime
            }
        }
    }
    
    @IBAction func showMainWindow(_ sender: NSMenuItem) {
        //print("Calling showWindow from the delegate")
        nc.post(Notification(name: Notification.Name(rawValue: "ShowMainWindow")))
        //showWindowDelegate?.seriouslyShowTheWindow()
    }

    @IBAction func closeWindow(_ sender: Any) {
        /*Because this view is presented using a Show segue it can't be dismissed with view.dismiss(self) I have to call back up to the window created to present it and tell that window to close*/
        self.view.window?.close()
    }
}

