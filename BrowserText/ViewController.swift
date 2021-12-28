//
//  ViewController.swift
//  BrowserText
//
//  Created by Fool on 2/26/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa
import WebKit
//Quartz is required to access the PDFKit framework
import Quartz
import JavaScriptCore
//import XCTest

//Protocol for getting data out of the webview
protocol webViewDataProtocol: AnyObject {
    var viewContent:String { get set }
    //FIXME: See about making just one function here and giving it a more useful name
    func getWebViewDataByID(_ id: String, completion: @escaping () -> Void)
    func getWebViewValueByID(_ id: String, dataType:String, completion: @escaping () -> Void)
    func getWebViewValueByClassName(_ name: String, index: Int,  completion: @escaping () -> Void)
    func getWebViewValueByJSFunction(_ name: String, completion: @escaping () -> Void)
    func getWebViewValueByQuerySelector(_ name: String, completion: @escaping () -> Void)
    func getWebViewValueByQuerySelectorAll(_ name: String, index: Int, completion: @escaping () -> Void)
}

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, webViewDataProtocol, WKScriptMessageHandler {
    
    @IBOutlet weak var theWebView: NSView!
    @IBOutlet weak var timeView: NSTextField!
    @IBOutlet weak var daysUntilPopup: NSPopUpButton!
    @IBOutlet var followupView: NSView!
    @IBOutlet weak var interfaceView: NSView!
    
    @IBOutlet weak var baseFolderPath: NSTextField!
    @IBOutlet weak var idView: NSTextField!
    
    var pfView:NSView!
    
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var viewContent = "Starting Text"
    var currentData = ChartData(chartData: "", aptTime: "", aptDate: 0)
    var visitTime = "00"
    
    //The URL of the Practice Fusion login page as opposed to their main page
    let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/login"
    //let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/PF/home/main"
    
    //JavaScript bits
    let context = JSContext()
    
    
    //FIXME: Give these more useful names based on what they actually do
    @IBOutlet weak var webPrintView: NSView!
    @IBOutlet weak var webViewForPrint: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //Open default web page into the browser view
        //Create a browser view
        pfView = makeWebViewWithURL(myPage)
        pfView.translatesAutoresizingMaskIntoConstraints = false

        //Add the browser view to it's storyboard created container view
        theWebView.addSubview(pfView)
        
        //Set the browser views constraints within it's container view
        pfView.leadingAnchor.constraint(equalTo: theWebView.leadingAnchor).isActive = true
        pfView.trailingAnchor.constraint(equalTo: interfaceView.leadingAnchor).isActive = true
        pfView.topAnchor.constraint(equalTo: theWebView.topAnchor).isActive = true
        pfView.bottomAnchor.constraint(equalTo: theWebView.bottomAnchor).isActive = true
        
        //FIXME: I'm not sure I need the UI Delegation
        (pfView as! WKWebView).uiDelegate = self
        (pfView as! WKWebView).navigationDelegate = self
        
        
        
    }
    
    override func viewDidAppear() {
        
    }
    
    
//Trying to figure out printing
    //This is a required function of conforming to the WKScriptMessageHandler protocol
    //and it receives the messages sent by the web page . . . but what to do with them?
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received \(message.name) message from frame with tag\n: \(message.frameInfo)")
//        let theWebView = message.webView!
        //printWebView()
        
        //"document.getElementById('print-chart-modal-content').innerHTML"
        (pfView as! WKWebView).evaluateJavaScript("window.print()", completionHandler: { (html: Any?, error: Error?) in
            let alert = NSAlert()
            alert.messageText = "You cannot yet print Practice Fusion data from this program.  Please use Practice Fusion from your regular browser to print."
            alert.beginSheetModal(for: self.view.window!, completionHandler: { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print(returnCode)
                return
            })
//            if error == nil {
//                print("No error in dealing with the object")
//            } else {
//                print("Error: \(error)")
//            }
        })
        //Using .innerText will grab the text from the PF generated report and pass it to the printer, though it does NOT pass on the formatting and returns something ugly and mostly unuseable in its current form.  I either need to figure out how to include the PF formatting, or do my own post retrieval formatting.  Using .innerHTML will grab the same data with all it's HTML tags.
//        (pfView as! WKWebView).evaluateJavaScript("document.getElementById('print-chart-modal-content').innerHTML",
//                                                  completionHandler: { (html: Any?, error: Error?) in
//                                                    //Check if an error's been returned, if not, continue
//                                                    if error == nil {
//                                                        print("No error in retrieving object")
//
//                                                        //Create a view to hold the final text so it can be passed to the NSPrintOperation
//                                                        let printView = NSTextView()
//                                                        //Set the size of the view or the text won't appear on the page
//                                                        printView.setFrameSize(NSSize(width: 680, height: 0))
//                                                        //Transfer the final string to the TextView's string property
//                                                        printView.string = html as! String
//                                                        let printInfo = NSPrintInfo.shared
//                                                        printInfo.leftMargin = 40
//                                                        printInfo.isVerticallyCentered = false
//                                                        printInfo.bottomMargin = 40
//                                                        let operation: NSPrintOperation = NSPrintOperation(view: printView, printInfo: printInfo)
//                                                        operation.run()
//
//                                                        let pasteBoard = NSPasteboard.general
//                                                        pasteBoard.clearContents()
//                                                        pasteBoard.setString(html as! String, forType: .string)
//
//                                                        //self.printWebView(html as! WKWebView)
//                                                        //(self.pfView as! WKWebView).loadHTMLString(html as! String, baseURL: nil)
//
//                                                        //Set the viewContent var to the data retrieved from the webview
//                                                        //if that retrieval fails, set the var to a default value
//                                                        //self.viewContent = (html as? String) ?? "No string"
//
//
//                                                    } else {
//                                                        print("Error: \(error)")
//                                                    }
//        })
    }
    
    //Click a button with JavaScript
   //document.getElementById('htmlbutton').click()
    
    //Function for other views to call back and get data out of the web view
    func getDataFromWebView(usingID id: String) -> String {
        var results = String()
        print("Calling getDataFromWebView via protocol and delegation")
        let dataHandler: () -> Void = {
            print("Inside the protocol dataHandler")
            results = self.viewContent
        }
        
        getWebViewDataByID(id, completion: dataHandler)
        print("Returning results from getDataFromWebView")
        return results
    }
    
    
    @IBAction func openPhoneMessage(_ sender: Any?) {
        print("manual segue activated")
        
        let pmHandler: () -> Void = {
            self.viewContent.copyToPasteboard()
            if self.viewContent.contains("DOB: ") {
            self.performSegue(withIdentifier: "showPhoneMessage", sender: self)
            } else {
                guard let theWindow = self.view.window else { return }
                print("No DOB")
                //After notifying the user, break out of the program
                MissingData().alertToMissingDataWithMessage(.clickElipsis, inWindow: theWindow)
            }
        }
        //getWebViewDataByID("ember3", completion: pmHandler)
        getWebViewValueByClassName("charts outlet", completion: pmHandler)

    }
    
    @IBAction func openReceipt(_ sender:Any?) {
        let receiptHandler: () -> Void = {
            self.performSegue(withIdentifier: "showReceipt", sender: nil)
        }
        //getWebViewDataByID("ember3", completion: receiptHandler)
        getWebViewValueByClassName("charts outlet", completion: receiptHandler)
    }
    
    @IBAction func openeScripts(_ sender: Any?) {
        let eScriptHandler: () -> Void = {
            self.performSegue(withIdentifier: "showeScript", sender: nil)
        }
        
        //getWebViewDataByID("ember3", completion: eScriptHandler)
        getWebViewValueByClassName("charts outlet", completion: eScriptHandler)
    }
    
    @IBAction func openPTVNBuilder(_ sender: Any?) {
        //print("Opening the PTVN Building module")
        //Create a completion handler to deal with the results of the JS call to the webView
        let assignmentHandler: () -> Void = {
            print("In the PTVN Builder assignmentHandler")
            if self.viewContent.contains("DOB: ") {
            self.currentData = ChartData(chartData: self.viewContent, aptTime: self.timeView.stringValue, aptDate: self.daysUntilPopup.indexOfSelectedItem)
            self.performSegue(withIdentifier: "showPTVNBuilder", sender: self)
            
            } else {
                guard let theWindow = self.view.window else { return }
                print("No DOB")
                //After notifying the user, break out of the program
                MissingData().alertToMissingDataWithMessage(.clickElipsis, inWindow: theWindow)
                //FIXME: Need to add a "Continue" button to the dialog and if it's pressed the program should continue to the phone message view with an empty ChartData object so a message can be taken for a non-patient.
            }
        }
        //getWebViewDataByID("ember3", completion: assignmentHandler)
        getWebViewValueByClassName("charts outlet", completion: assignmentHandler)
    }
    
    @IBAction func openLabLetter(_ sender: Any?) {
        //FIXME: Need to check the text to make sure we're showing lab results before continuing
        
        let assignmentHandler: () -> Void = {
            self.performSegue(withIdentifier: "showLabLetter", sender: self)
        }
        
        //getWebViewDataByID("ember3", completion: assignmentHandler)
        getWebViewValueByClassName("charts outlet", completion: assignmentHandler)
    }
    
    @IBAction func openFormLetters(_sender: Any?) {
        let assignmentHandler: () -> Void = {
            self.performSegue(withIdentifier: "showFormLetters", sender: self)
        }
        
        //getWebViewValueByID("ember3", dataType: "innerHTML", completion: assignmentHandler)
        //getWebViewDataByID("ember3", completion: assignmentHandler)
        getWebViewValueByClassName("charts outlet", completion: assignmentHandler)
    }
    
    @IBAction func openLabs(_sender: Any?) {
        let assignmentHandler: () -> Void = {
            self.performSegue(withIdentifier: "showLabs", sender: self)
        }
        
        //getWebViewDataByID("ember3", completion: assignmentHandler)
        getWebViewValueByClassName("charts outlet", completion: assignmentHandler)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoneMessage":
            if let toViewController = segue.destinationController as? PhoneMessageVC {
                //print("opening new Phone Message")
                toViewController.viewDataDelegate = self
                toViewController.patientData = self.viewContent
            }
        case "showReceipt":
            if let toViewController = segue.destinationController as? ReceiptVC {
                toViewController.viewDataDelegate = self
                toViewController.patientData = self.viewContent
            }
        case "showPTVNBuilder":
            if let toViewController = segue.destinationController as? BuilderInterfaceVC {
                //print("entering PTVN Builder module")
                toViewController.viewDataDelegate = self
                toViewController.currentData = self.currentData
            }
        case "showeScript":
            if let toViewController = segue.destinationController as? eScriptVC {
                toViewController.viewDataDelegate = self
                toViewController.theText = self.viewContent
            }
        case "showLabLetter":
            if let toViewController = segue.destinationController as? LabViewController {
                toViewController.viewDataDelegate = self
                toViewController.rawLabData = self.viewContent
            }
        case "showFormLetters":
            if let toViewController = segue.destinationController as? FormLettersVC {
                toViewController.viewDataDelegate = self
                toViewController.theText = self.viewContent
            }
        case "showLabs":
            if let toViewController = segue.destinationController as? LabsViewController {
                toViewController.viewDataDelegate = self
                toViewController.theText = self.viewContent
            }
        default:
            return
        }
    }
    
    @IBAction func selectBaseFolder(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        let dialog = NSOpenPanel();

        dialog.title                   = "Locate WPCMSharedFiles folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = true;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                let path: String = result!.path
                baseFolderPath.stringValue = path
                defaults.set(path, forKey: "baseFolderPath")
                print(path)
            }
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    private func makeWebViewWithURL(_ address:String) -> NSView {
        
        //Creates a script then injects it into each frame of the web page when it's done loading
        //let configuration = WKWebViewConfiguration()
            //Not sure what this 'source' is or how it works
//        let script = WKUserScript(source: "window.print = function() { window.webkit.messageHandlers.print.postMessage('print') }", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
//        configuration.userContentController.addUserScript(script)
//        configuration.userContentController.add(self, name: "print")
        //None of these preferences fix the printing from PF issue
//        configuration.preferences.javaScriptEnabled = true
//        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
//        configuration.preferences.javaEnabled = true
//        configuration.preferences.plugInsEnabled = true
        //let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.1 Safari/605.1.15"

        //let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        //webView.customUserAgent = userAgent
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        //Trying to figure out how to get Practice Fusion to interact with the program in a more normal way by assigning a user agent.  This did not fix the general problem loading on older systems or with printing, but it may have dealt with some of the cookie issues.  Will need to figure out how to get and present the user agent most accurate to the system the probram is running on.
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"
        webView.load(URLRequest(url: URL(string: address)!))
        
        return webView
    }
    
    
    @IBAction func getDataFromBrowser(_ sender: Any) {
        //Create a completion handler to deal with the results of the JS call to the webView
        let assignmentHandler: () -> Void = {
            print("Copying to clipboard")
            //self.viewContent.copyToPasteboard()
            //self.currentData = ChartData(chartData: self.viewContent, aptTime: self.timeView.stringValue, aptDate: self.daysUntilPopup.indexOfSelectedItem)

        }
        

        //getWebViewDataByID("ember3", completion: assignmentHandler)
        //getWebViewDataByID("ember839", completion: assignmentHandler)
        
        //This will get the text out of the webview, but it's not pretty and may not be parsable by my existing functions
//        (pfView as! WKWebView).evaluateJavaScript("document.body.textContent") { (string, error) in
//            print("Copying view contents to clipboard")
//            if let theString = string as? String {
//                theString.copyToPasteboard()
//            }
//        }
        
//        (pfView as! WKWebView).evaluateJavaScript("document.getElementsByClassName('charts outlet')[0].textContent", completionHandler: { (result:Any?, error:Error?) in
//            if error == nil {
//                print("No error. Attempting to conver data to string and copy to clipboard.")
//                let theResults = (result as? String) ?? "Unable to convert results to string."
//                theResults.copyToPasteboard()
//            } else {
//                print("ERROR\n\(String(describing: error))")
//            }
//        })
        
        (pfView as! WKWebView).evaluateJavaScript("document.querySelectorAll('[data-element=plan-name]')[0].innerText", completionHandler: { (result:Any?, error:Error?) in
            
            if error == nil {
                print("No error. Attempting to conver data to string and copy to clipboard.")
                let theResults = (result as? String) ?? "Unable to convert results to string."
                theResults.copyToPasteboard()
            } else {
                print("ERROR\n\(String(describing: error))")
            }
        })
        
    }
    
    
    //Gets the underlying text for the Patient Summary page in Practice Fusion
    func getWebViewDataByID(_ id: String, completion: @escaping () -> Void) {
        print("Getting summary data")
        //Using ID 'ember311' I get the same text as I do by selecting all and copying
        (pfView as! WKWebView).evaluateJavaScript("document.getElementById('\(id)').innerText",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    //Check if an error's been returned, if not, continue
                                    if error == nil {
                                        print("Assigning data to viewContent")
                                        //Set the viewContent var to the data retrieved from the webview
                                        //if that retrieval fails, set the var to a default value
                                        self.viewContent = (html as? String) ?? "No string"
                                        //Run the completion handler passed in as a parameter
                                        (html as? String)?.copyToPasteboard()
                                        completion()
                                    } else {
                                        print(error)
                                    }
        })
        
    }

    @IBAction func printSelection(_ sender: Any) {
        print("In printSelection")
        let printHandler: () -> Void = {
            print("In printHandler")
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(self.viewContent, forType: .string)
            print("viewContent contains:\n \(self.viewContent)")
        }
        
        getWebViewValueByID(idView.stringValue, dataType: "innerHTML", completion: printHandler)
    }
    
    //Gets the underlying values for the Patient Profile page in Practice Fusion (use .value to get the value after getElementById())
    func getWebViewValueByID(_ id: String, dataType:String = "value", completion: @escaping () -> Void) {
        //print("Getting ID data")
        //Using .value I can retrieve the data from a form field if I know it's ID
        (pfView as! WKWebView).evaluateJavaScript("document.getElementById('\(id)').\(dataType)",
            completionHandler: { (html: Any?, error: Error?) in
                //Check if an error's been returned, if not, continue
                if error == nil {
                    //print("Assigning data to viewContent")
                    //Set the viewContent var to the data retrieved from the webview
                    //if that retrieval fails, set the var to a default value
                    
                    self.viewContent = (html as? String) ?? "No string"
                    //Run the completion handler passed in as a parameter
                    completion()
                } else {
                    print("Error: \(String(describing: error))")
                }
        })
        
    }
//"document.getElementsByClassName('\(name)')[0].innerHTML"
    func getWebViewValueByClassName(_ name:String, index:Int = 0, completion: @escaping () -> Void) {
        (pfView as! WKWebView).evaluateJavaScript("document.getElementsByClassName('\(name)')[0].innerText", completionHandler: { (result:Any?, error:Error?) in
            if error == nil {
                print("No error. Attempting to conver data to string and copy to clipboard.")
                self.viewContent = (result as? String) ?? "Unable to convert results to string."
                self.viewContent.copyToPasteboard()
                completion()
            } else {
                print("ERROR\n\(String(describing: error))")
                
                //FIX ME: Probably not the ideal way to handle this.
                //These were added to handle the JavaScript error occurring when creating a PTVN for a new patient
                //Because there is no previous note on which to execute the JS function, the function was erroring
                //out and stopping the PTVN creation process.
                self.viewContent = "A JavaScript exception occured."
                completion()
            }
        })
//        let js = """
//document.querySelectorAll('[data-element*=\(name)]')[\(index)].innerHTML
//"""
//        (pfView as! WKWebView).evaluateJavaScript(js, completionHandler: { (html: Any?, error: Error?) in
//            if error == nil {
//                self.viewContent = html as? String ?? "No string"
//                completion()
//            } else {
//                print("Error: \(String(describing: error))")
//            }
//        })
    }
    
    func getWebViewValueByJSFunction(_ function:String, completion: @escaping () -> Void) {
        let js = """
Array.from(document.querySelectorAll('[class*=data-grid-cell]')).map(med => med.innerText).join(' * ');

"""
        //[data-element*=\(function)]
   (pfView as! WKWebView).evaluateJavaScript(js, completionHandler: { (html: Any?, error: Error?) in
            if error == nil {
                self.viewContent = html as? String ?? "No string"
                completion()
            } else {
                print("Error: \(String(describing: error))")
            }
        })
    }
    
    
    func getWebViewValueByQuerySelector(_ name:String, completion: @escaping () -> Void) {
        (pfView as! WKWebView).evaluateJavaScript("document.querySelector('[\(name)]').innerText", completionHandler: { (result: Any?, error: Error?) in
            if error == nil {
                //print ("Assigning data to viewContent")
                self.viewContent = (result as? String) ?? "Unable to convert results to string."
                self.viewContent.copyToPasteboard()
                completion()
            } else {
                print("Error: \(String(describing: error))")
            }
        })
    }
    
    func getWebViewValueByQuerySelectorAll(_ name:String, index: Int, completion: @escaping () -> Void) {
        (pfView as! WKWebView).evaluateJavaScript("document.querySelectorAll('[\(name)]')[\(index)].innerText", completionHandler: { (result: Any?, error: Error?) in
            if error == nil {
                //print ("Assigning data to viewContent")
                self.viewContent = (result as? String) ?? "Unable to convert results to string."
                self.viewContent.copyToPasteboard()
                completion()
            } else {
                print("Error: \(String(describing: error))")
            }
        })
    }
    
    func printWebView(_ view: WKWebView) {

        let printInfo = NSPrintInfo.shared
        printInfo.paperSize = NSMakeSize(595.22, 841.85)
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = true
        printInfo.orientation = .portrait
        printInfo.topMargin = 50
        printInfo.rightMargin = 0
        printInfo.bottomMargin = 50
        printInfo.leftMargin = 0
        printInfo.verticalPagination = .automatic
        printInfo.horizontalPagination = .fit
        //webView.mainFrame.frameView.printOperation(with: printInfo).run()
        let printOp: NSPrintOperation = NSPrintOperation(view: view, printInfo: printInfo)
        //let printOp: NSPrintOperation = NSPrintOperation(view: (pfView as! WKWebView).mainFrame.frameView.documentView, printInfo: printInfo)
        printOp.showsPrintPanel = true
        printOp.showsProgressPanel = false
        printOp.run()
    }
    
//    func makePDF(at url: URL, for webView: WKWebView, printInfo: NSPrintInfo) throws {
//        webView.preferences.shouldPrintBackgrounds = true
//
//        guard let printOp = webView.mainFrame.frameView.printOperation(with: printInfo) else {
//            throw MyPrintError.couldntGetPrintOperation // or something like this
//        }
//
//        let session = PMPrintSession(printOp.printInfo.pmPrintSession())
//        let settings = PMPrintSettings(printOp.printInfo.pmPrintSettings())
//
//        if PMSessionSetDestination(session,
//                                   settings,
//                                   PMDestinationType(kPMDestinationFile),
//                                   kPMDocumentFormatPDF as CFString,
//                                   url as CFURL) != noErr {
//            throw MyPrintError.couldntSetDestination // or something like this
//        }
//
//        printOp.showsPrintPanel = false
//        printOp.run()
//    }
    
//    func printCurrentPage() {
//
//
//        let printController = print
//        let printFormatter = self.webView.viewPrintFormatter()
//        printController?.printFormatter = printFormatter
//
//        let completionHandler: UIPrintInteractionCompletionHandler = { (printController, completed, error) in
//            if !completed {
//                if let e = error? {
//                    println("[PRINT] Failed: \(e.domain) (\(e.code))")
//                } else {
//                    println("[PRINT] Canceled")
//                }
//            }
//        }
//
//        if let controller = printController? {
//            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//                controller.presentFromBarButtonItem(someBarButtonItem, animated: true, completionHandler: completionHandler)
//            } else {
//                controller.presentAnimated(true, completionHandler: completionHandler)
//            }
//        }
//    }
    
    @IBAction func upDatePage(_ sender:NSButton) {
        let newPage = idView.stringValue
        
        pfView = makeWebViewWithURL(newPage)
        pfView.translatesAutoresizingMaskIntoConstraints = false

        //Add the browser view to it's storyboard created container view
        theWebView.addSubview(pfView)
        
        //Set the browser views constraints within it's container view
        pfView.leadingAnchor.constraint(equalTo: theWebView.leadingAnchor).isActive = true
        pfView.trailingAnchor.constraint(equalTo: interfaceView.leadingAnchor).isActive = true
        pfView.topAnchor.constraint(equalTo: theWebView.topAnchor).isActive = true
        pfView.bottomAnchor.constraint(equalTo: theWebView.bottomAnchor).isActive = true
        
        //FIXME: I'm not sure I need the UI Delegation
        (pfView as! WKWebView).uiDelegate = self
        (pfView as! WKWebView).navigationDelegate = self
        
        func webView(_ webView: WKWebView,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
        {
            if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
            {
                let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential, cred)
            }
            else
            {
                completionHandler(.performDefaultHandling, nil)
            }
        }
        
    }


}

enum EmberID:String {
    case ember311
    case printView = "print-chart-modal-content"
}

enum MyPrintError:Error {
    case couldntGetPrintOperation
    case couldntSetDestination
}

func getEmberIDFromScrapedString(_ data:String) -> String {
    var result = String()
    let theLine = data.simpleRegExMatch("data-element=\"last-name\".*?shorter ember-view\"")
    result = theLine.simpleRegExMatch("ember\\d{3,7}")
    print(result)
    return result
}

//func getEmberIDForPtOutlet(_ data:String) -> String {
//    var result = String()
//    let theLine = data.simpleRegExMatch("div id=​\"ember\\d{4,7}\" class=​\"patient-summary flex-column flex-grow view-spinner ember-view\">")
//    result = theLine.simpleRegExMatch("ember\\d{4,7}")
//    print("The regex match is: \(result)")
//    return result
//}

