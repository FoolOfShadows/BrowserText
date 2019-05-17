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
    func getDataFromWebView(usingID id: String) -> String
}

class ViewController: NSViewController, WKNavigationDelegate, webViewDataProtocol {
    
    
    @IBOutlet weak var theWebView: NSView!
    @IBOutlet weak var timeView: NSTextField!
    @IBOutlet weak var daysUntilPopup: NSPopUpButton!
    @IBOutlet var followupView: NSView!
    @IBOutlet weak var interfaceView: NSView!
    
    var pfView:NSView!
    
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var viewContent = "Starting Text"
    var currentData = ChartData(chartData: "", aptTime: "", aptDate: 0)
    var visitTime = "00"
    
    let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/login"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //Set an observer on the pfView to watch its estimatedProgress value and report back the new value as it changes
        //pfView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    //Function for other views to call back and get data out of the web view
    func getDataFromWebView(usingID id: String) -> String {
        var results = String()
        //print("Calling getDataFromWebView via protocol and delegation")
        let dataHandler: () -> Void = {
            //print("Inside the protocol dataHandler")
            results = self.viewContent
        }
        
        getWebViewDataByID(id, completion: dataHandler)
        return results
    }

    
    //Can tell if the main page has loaded but not if a frame in the page has loaded new content
//    func webView(_ webView: WKWebView,
//                 didFinish navigation: WKNavigation!){
//        //print("loaded")
//    }
    
    
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
            
        default:
            return
        }
    }
    
    private func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: myPage)!))
        
        return webView
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
    private func getWebViewDataByID(_ id: String, completion: @escaping () -> Void) {
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



}
