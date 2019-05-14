//
//  ViewController.swift
//  BrowserText
//
//  Created by Fool on 2/26/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa
import WebKit

//protocol webViewDataProtocol: class {
//    func returnPTVNValues(sender: NSViewController)
//}

class ViewController: NSViewController, WKNavigationDelegate {
    
    @IBOutlet weak var theWebView: NSView!
    @IBOutlet weak var timeView: NSTextField!
    @IBOutlet weak var daysUntilPopup: NSPopUpButton!
    @IBOutlet var followupView: NSView!
    @IBOutlet weak var interfaceView: NSView!
    
    var pfView:NSView! /*: NSView = NSView() {
        didSet {
            if let pfWebView = (self.pfView as? WKWebView) {
                
            }
        }
    }*/
    
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var viewContent = "Starting Text"
    var currentData = ChartData(chartData: "", aptTime: "", aptDate: "")
    var visitTime = "00"
    
    let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/login"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Open default web page into the browser view
        pfView = makeWebView()
        pfView.translatesAutoresizingMaskIntoConstraints = false
        theWebView.addSubview(pfView)
        
        pfView.leadingAnchor.constraint(equalTo: theWebView.leadingAnchor).isActive = true
        pfView.trailingAnchor.constraint(equalTo: interfaceView.leadingAnchor).isActive = true
        pfView.topAnchor.constraint(equalTo: theWebView.topAnchor).isActive = true
        pfView.bottomAnchor.constraint(equalTo: theWebView.bottomAnchor).isActive = true
        
        //pfView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "estimatedProgress" {
//            print(Float((pfView as! WKWebView).estimatedProgress))
//        }
//    }
    //Can tell if the main page has loaded but not if a frame in the page has loaded new content
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!){
        print("loaded")
    }
    
    
    @IBAction func openPhoneMessage(_ sender: Any?) {
        print("manual segue activated")
        let pmHandler: () -> Void = {
            //self.viewContent.copyToPasteboard()
            self.performSegue(withIdentifier: "showPhoneMessage", sender: self)
        }
        getWebViewDataByID("ember311", completion: pmHandler)
        
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoneMessage":
            if let toViewController = segue.destinationController as? PhoneMessageVC {
                print("opening new Phone Message")
                toViewController.patientData = self.viewContent
                let pmHandler: () -> Void = {
                    //self.viewContent.copyToPasteboard()
                    toViewController.patientData = self.viewContent
                }
                getWebViewDataByID("ember311", completion: pmHandler)
                //toViewController.patientData = self.viewContent
            }
        case "showBuilder":
            if let toViewController = segue.destinationController as? BuilderInterfaceVC {
            //Get the info from the date scheduled popup menu
            ptVisitDate = daysUntilPopup.indexOfSelectedItem
            //Set the files save location based on the users selection
            //var saveLocation = "Desktop"
            switch ptVisitDate {
            case 0:
                saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
            case 1...4:
                saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
            default:
                saveLocation = "Desktop"
            }
            
            visitTime = timeView.stringValue
            
            //Create a completion handler to deal with the results of the JS call to the webView
            let assignmentHandler: () -> Void = {
                //print("Copying to clipboard")
                //self.viewContent.copyToPasteboard()
                toViewController.currentData = ChartData(chartData: self.viewContent, aptTime: self.timeView.stringValue, aptDate: "")
                
            }
            
            getWebViewDataByID("ember311", completion: assignmentHandler)
            }
            
        default:
            return
        }
//        if segue.identifier == "showPhoneMessage" {
//            if let toViewController = segue.destinationController as? PhoneMessageVC {
//                print("opening new Phone Message")
//                //toViewController.patientData = self.viewContent
//                let pmHandler: () -> Void = {
//                    //self.viewContent.copyToPasteboard()
//                    toViewController.patientData = self.viewContent
//                }
//                getWebViewDataByID("ember311", completion: pmHandler)
//                //toViewController.patientData = self.viewContent
//            }
//        }
    }
    
    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: myPage)!))
        
        return webView
    }
    
    @IBAction func getDataFromBrowser(_ sender: Any) {
        
        //Get the info from the date scheduled popup menu
        ptVisitDate = daysUntilPopup.indexOfSelectedItem
        //Set the files save location based on the users selection
        //var saveLocation = "Desktop"
        switch ptVisitDate {
        case 0:
            saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
        case 1...4:
            saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
        default:
            saveLocation = "Desktop"
        }
        
        visitTime = timeView.stringValue
        
        //Create a completion handler to deal with the results of the JS call to the webView
        let assignmentHandler: () -> Void = {
            //print("Copying to clipboard")
            //self.viewContent.copyToPasteboard()
            self.currentData = ChartData(chartData: self.viewContent, aptTime: self.timeView.stringValue, aptDate: "")
            
        }
        
        getWebViewDataByID("ember311", completion: assignmentHandler)
        
        print("Data: \(viewContent)")
        //currentData = ChartData(chartData: viewContent)
        
        
    }
    
    
    //Gets the underlying text for the Patient Summary page in Practice Fusion
    private func getWebViewDataByID(_ id: String, completion: @escaping () -> Void) {
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
                                        completion()
                                    }
        })
        
    }



}
