//
//  ViewController.swift
//  BrowserText
//
//  Created by Fool on 2/26/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa
import WebKit

protocol webViewDataProtocol: class {
    var viewContent:String { get set }
    //func getDataFromWebView(usingID id: String) -> String
    func getWebViewDataByID(_ id: String, completion: @escaping () -> Void)
}

class ViewController: NSViewController, WKNavigationDelegate, webViewDataProtocol, WKScriptMessageHandler {
    
    //Trying to figure out printing
    //This is a required function of conforming to the WKScriptMessageHandler protocol
    //and it receives the messages send by the web page . . . but what to do with them?
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("Received \(message.name) message from page.")
//        (pfView as! WKWebView).evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
//            print(html)
//        })
    }
    
    /// Handle javascript:confirm(...)
//    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
//
//        let printAction = UIAlertAction(title: Okay, style: .Default) { _ in
//            completionHandler(true)
//        }
//
//    }
    
    
    @IBOutlet weak var theWebView: NSView!
    @IBOutlet weak var timeView: NSTextField!
    @IBOutlet weak var daysUntilPopup: NSPopUpButton!
    @IBOutlet var followupView: NSView!
    @IBOutlet weak var interfaceView: NSView!
    
    @IBOutlet weak var idView: NSTextField!
    
    var pfView:NSView!
    
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var viewContent = "Starting Text"
    var currentData = ChartData(chartData: "", aptTime: "", aptDate: 0)
    var visitTime = "00"
    
    let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/login"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let configuration = WKWebViewConfiguration()
//        let script = WKUserScript(source: "window.print = function() { window.webkit.messageHandlers.print.postMessage('print') }", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
//        configuration.userContentController.addUserScript(script)
//        configuration.userContentController.add(self, name: "print")
//        self.webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        //Open default web page into the browser view
        //Create a browser view
        pfView = makeWebView()
        pfView.translatesAutoresizingMaskIntoConstraints = false

        //Add the browser view to it's storyboard created container view
        theWebView.addSubview(pfView)
        
        //Set the browser views constraints withing it's container view
        pfView.leadingAnchor.constraint(equalTo: theWebView.leadingAnchor).isActive = true
        pfView.trailingAnchor.constraint(equalTo: interfaceView.leadingAnchor).isActive = true
        pfView.topAnchor.constraint(equalTo: theWebView.topAnchor).isActive = true
        pfView.bottomAnchor.constraint(equalTo: theWebView.bottomAnchor).isActive = true
    }
    
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
        //print("manual segue activated")
        let pmHandler: () -> Void = {
            //self.viewContent.copyToPasteboard()
            if self.viewContent.contains("DOB: ") {
            self.performSegue(withIdentifier: "showPhoneMessage", sender: self)
            } else {
                guard let theWindow = self.view.window else { return }
                print("No DOB")
                //After notifying the user, break out of the program
                let theAlert = NSAlert()
                theAlert.messageText = "It looks like you haven't clicked the elipses to reveal the patients date of birth.  Give it another shot."
                theAlert.beginSheetModal(for: theWindow) { (NSModalResponse) -> Void in
                    let returnCode = NSModalResponse
                    print(returnCode)}
            }
        }
        getWebViewDataByID("ember311", completion: pmHandler)

    }
    
    @IBAction func openeScripts(_ sender: Any?) {
        let eScriptHandler: () -> Void = {
            self.performSegue(withIdentifier: "showeScript", sender: nil)
        }
        
        getWebViewDataByID("ember311", completion: eScriptHandler)
    }
    
    @IBAction func openPTVNBuilder(_ sender: Any?) {
        //print("Opening the PTVN Building module")
        //Create a completion handler to deal with the results of the JS call to the webView
        let assignmentHandler: () -> Void = {
            //print("In the PTVN Builder assignmentHandler")
            if self.viewContent.contains("DOB: ") {
            self.currentData = ChartData(chartData: self.viewContent, aptTime: self.timeView.stringValue, aptDate: self.daysUntilPopup.indexOfSelectedItem)
            self.performSegue(withIdentifier: "showPTVNBuilder", sender: self)
            
            } else {
                guard let theWindow = self.view.window else { return }
                print("No DOB")
                //After notifying the user, break out of the program
                let theAlert = NSAlert()
                theAlert.messageText = "It looks like you haven't clicked the elipses to reveal the patients date of birth.  Give it another shot."
                theAlert.beginSheetModal(for: theWindow) { (NSModalResponse) -> Void in
                    let returnCode = NSModalResponse
                    print(returnCode)}
            }
        }
        
        getWebViewDataByID("ember311", completion: assignmentHandler)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoneMessage":
            if let toViewController = segue.destinationController as? PhoneMessageVC {
                //print("opening new Phone Message")
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
        default:
            return
        }
    }
    
    private func makeWebView() -> NSView {
        
        //Creates a script then injects it into each frame of the web page when it's done loading
        let configuration = WKWebViewConfiguration()
            //Not sure what this 'source' is or how it works
        let script = WKUserScript(source: "window.print = function() { window.webkit.messageHandlers.print.postMessage('print') }", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(self, name: "print")
        //None of these preferences fix the printing from PF issue
//        configuration.preferences.javaScriptEnabled = true
//        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
//        configuration.preferences.javaEnabled = true
//        configuration.preferences.plugInsEnabled = true
        //let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.1 Safari/605.1.15"
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        //webView.customUserAgent = userAgent
        
        //let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: myPage)!))
        
        return webView
    }
    
    func _webView(webView: WKWebView!, printFrame: WKFrameInfo) {
        print("JS: window.print()")
    }
    
    @IBAction func getDataFromBrowser(_ sender: Any) {
        //Create a completion handler to deal with the results of the JS call to the webView
        let assignmentHandler: () -> Void = {
            //print("Copying to clipboard")
            //self.viewContent.copyToPasteboard()
            self.currentData = ChartData(chartData: self.viewContent, aptTime: self.timeView.stringValue, aptDate: self.daysUntilPopup.indexOfSelectedItem)
            
        }
        
        getWebViewDataByID("ember311", completion: assignmentHandler)
        
        //print("Data: \(viewContent)")
        //currentData = ChartData(chartData: viewContent)
        
        
    }
    
    
    //Gets the underlying text for the Patient Summary page in Practice Fusion
    func getWebViewDataByID(_ id: String, completion: @escaping () -> Void) {
        //print("Getting summary data")
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
                                        completion()
                                    }
        })
        
    }

    @IBAction func printSelection(_ sender: Any) {
        print("In printSelection")
        let printHandler: () -> Void = {
            print("In printHandler")
//            let pasteBoard = NSPasteboard.general
//            pasteBoard.clearContents()
//            pasteBoard.setString(self.viewContent, forType: .string)
            print("viewContent contains:\n \(self.viewContent)")
        }
        
        getWebViewDataByID(idView.stringValue, completion: printHandler)
    }
    
//    func printCurrentPage() {
//
//
//        let printController = UIPrintInteractionController.sharedPrintController()
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
    

}

enum EmberID:String {
    case ember311
}
